#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use DBI                ();
use Encode             qw( decode_utf8 encode_utf8 );
use FindBin            ();
use Path::Tiny         qw( path );
use Test2::V0          qw( dies done_testing is like mock ok subtest );
use Unicode::Normalize qw( NFD );
use URI::Escape        qw( uri_escape_utf8 );

no warnings "experimental::signatures";

my $Base = path($FindBin::Bin)->parent;

sub load_script () {
  do "$Base/utils/playlist_sync" or die "Cannot load the script ($@$!)";
}

load_script();
ok $INC{"DBD/SQLite.pm"}, "the script loads DBD::SQLite itself";

package FakeHttp {

  sub new ($class, $responses = {}) {
    bless { responses => $responses, calls => [] }, $class
  }

  sub request ($self, $method, $url, $options = {}) {
    my ($path) = $url =~ m|^https?://[^/]+(.*)$|;
    push $self->{calls}->@*, "$method $path";
    $self->{headers} = $options->{headers};
    my $content = $self->{responses}{"$method $path"};
    $content = shift @$content if ref $content;
    return {
      success => 1,
      status  => 200,
      content => Encode::encode_utf8($content),
      }
      if defined $content;
    { success => 0, status => 404, reason => "Not Found", content => "" }
  }

  sub post_form ($self, $url, $form, @) {
    my $login = $form->{"user[login]"};
    push $self->{calls}->@*, "POST $url $login";
    my $content = $self->{responses}{"POST $url"};
    return {
      success => 1,
      status  => 201,
      content => Encode::encode_utf8($content),
      }
      if defined $content;
    { success => 0, status => 401, reason => "Unauthorized", content => "" }
  }
}

my $Playlists_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Playlist ratingKey="10" title="Trance" playlistType="audio" smart="0"
    leafCount="3"/>
  <Playlist ratingKey="11" title="Films" playlistType="video" smart="0"
    leafCount="1"/>
  <Playlist ratingKey="12" title="Recent" playlistType="audio" smart="1"
    leafCount="5"/>
  <Playlist ratingKey="13" title="Chill" playlistType="audio" smart="0"
    leafCount="1"/>
  </MediaContainer>
  XML

my $Items_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="3">
  <Track ratingKey="101" playlistItemID="1001" title="Song A"
    grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="102" playlistItemID="1002" title="Song B"
    grandparentTitle="Artist">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="101" playlistItemID="1003" title="Song A"
    grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

my $Sections_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="2">
  <Directory key="1" type="artist" title="Music"/>
  <Directory key="2" type="movie" title="Films"/>
  </MediaContainer>
  XML

my $Tracks_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Track ratingKey="101" title="Song A" grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="102" title="Song B" grandparentTitle="Artist">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="103" title="Thé" grandparentTitle="Other">
    <Media id="3"><Part id="3" file="/srv/music/Other/Album/01 Thé.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="104" title="No file" grandparentTitle="Other"/>
  </MediaContainer>
  XML

sub plex ($responses = {}) {
  my $http = FakeHttp->new($responses);
  { http => $http, server => "http://plex.test:32400", token => "tok" }
}

subtest "plex playlists" => sub {
  my $plex = plex({ "GET /playlists" => $Playlists_xml });
  is PlaylistSync::plex_playlists($plex), [
      { id => 10, title => "Trance", smart => 0, count => 3 },
      { id => 12, title => "Recent", smart => 1, count => 5 },
      { id => 13, title => "Chill",  smart => 0, count => 1 },
    ],
    "audio playlists in server order";
};

subtest "plex playlist items" => sub {
  my $plex = plex({ "GET /playlists/10/items" => $Items_xml });
  is PlaylistSync::plex_playlist_items($plex, 10), [
      {
        item_id => 1001,
        key     => 101,
        path    => "/srv/music/Artist/Album/01 Song A.mp3",
        title   => "Song A",
        artist  => "Artist",
      }, {
        item_id => 1002,
        key     => 102,
        path    => "/srv/music/Artist/Album/02 Song B.mp3",
        title   => "Song B",
        artist  => "Artist",
      }, {
        item_id => 1003,
        key     => 101,
        path    => "/srv/music/Artist/Album/01 Song A.mp3",
        title   => "Song A",
        artist  => "Artist",
      },
    ],
    "items in order with duplicates kept";
};

subtest "plex library tracks" => sub {
  my $plex = plex({
    "GET /library/sections"               => $Sections_xml,
    "GET /library/sections/1/all?type=10" => $Tracks_xml,
  });
  is PlaylistSync::plex_library_tracks($plex), [
      { key => 101, path => "/srv/music/Artist/Album/01 Song A.mp3" },
      { key => 102, path => "/srv/music/Artist/Album/02 Song B.mp3" },
      { key => 103, path => "/srv/music/Other/Album/01 Thé.mp3" },
    ],
    "tracks with files from the music section";
  is $plex->{http}{calls},
    [ "GET /library/sections", "GET /library/sections/1/all?type=10" ],
    "does not fetch the film section";
};

subtest "plex request failure" => sub {
  my $plex = plex;
  like dies { PlaylistSync::plex_request($plex, "GET", "/missing") },
    qr/404 Not Found/, "dies with the status";
};

subtest "roots" => sub {
  my $local = {
    "t/Artist/Album/01 Song A.mp3" => 1,
    "Artist/Album/02 Song B.mp3"   => 1,
  };
  my $tracks = [
    { key => 1, path => undef },
    { key => 2, path => "/srv/music/Nope/x.mp3" },
    { key => 3, path => "/srv/music/Artist/Album/01 Song A.mp3" },
  ];
  is PlaylistSync::detect_roots($tracks, $local),
    { plex => "/srv/music/", local => "t/" },
    "roots from the first track found locally";
  is PlaylistSync::detect_roots(
    [ { key => 4, path => "/srv/music/Artist/Album/02 Song B.mp3" } ], $local
    ),
    { plex => "/srv/music/", local => "" },
    "a collection that mirrors the library directly";
  is PlaylistSync::detect_roots([ $tracks->[1] ], $local), undef,
    "undef when nothing matches";
  is PlaylistSync::detect_roots(
    [ { key => 5, path => "x.mp3" } ],
    { "x.mp3" => 1 }
    ),
    { plex => "/", local => "" }, "a bare file name on both sides";
  is PlaylistSync::roots({ plex_root => "/x/", local_root => "y/" }, [],
    $local), { plex => "/x/", local => "y/" }, "options override detection";
  is PlaylistSync::roots({}, [], $local), { plex => undef, local => "" },
    "no roots without a match";
  is PlaylistSync::plex_rel("/srv/", "/srv/a.mp3"), "a.mp3",
    "path under the root";
  is PlaylistSync::plex_rel("/srv/", "/other/a.mp3"), undef,
    "path outside the root";
  is PlaylistSync::plex_rel(undef,   "/srv/a.mp3"), undef, "no root known";
  is PlaylistSync::plex_rel("/srv/", undef), undef, "track without a file";
  is PlaylistSync::local_rel("t/", "t/a.mp3"), "a.mp3",
    "path under the folder";
  is PlaylistSync::local_rel("t/", "u/a.mp3"), undef,
    "path outside the folder";
  is PlaylistSync::local_rel("",   "a.mp3"), "a.mp3", "no folder prefix";
  is PlaylistSync::local_rel("t/", undef),   undef,   "item without a path";
};

sub make_db ($dir) {
  my $path = "$dir/strawberry.db";
  my $dbh  = DBI->connect(
    "dbi:SQLite:dbname=$path", "", "",
    { RaiseError => 1, sqlite_unicode => 1 }
  );
  my $schema = path("$Base/t/data/strawberry_schema.sql")->slurp_utf8;
  $dbh->do($_) for grep /\S/, split /;\n/, $schema;
  $dbh->do(
    "INSERT INTO directories (path, subdirs) VALUES (?, 1)", undef,
    "$dir/mp3s"
  );
  ($dbh, $path)
}

sub file_url ($path) {
  "file://" . uri_escape_utf8($path, "^A-Za-z0-9\\-._~/")
}

sub add_song ($dbh, $root, $rel, $title, $artist, $unavailable = 0) {
  $dbh->do(
    "INSERT INTO songs (url, directory_id, title, artist, album, unavailable)
     VALUES (?, 1, ?, ?, 'Album', ?)", undef, file_url("$root/$rel"), $title,
    $artist, $unavailable
  );
  $dbh->sqlite_last_insert_rowid
}

my $Songs = [
  [ "Artist/Album/01 Song A.mp3",  "Song A", "Artist" ],
  [ "Artist/Album/02 Song B.mp3",  "Song B", "Artist" ],
  [ NFD("Other/Album/01 Thé.mp3"), "Thé",    "Other" ],
];

sub add_songs ($dbh, $root, $prefix = "") {
  map add_song($dbh, $root, "$prefix$_->[0]", @$_[ 1, 2 ]), @$Songs
}

sub add_playlist ($dbh, $name, $favourite, @song_ids) {
  $dbh->do(
    "INSERT INTO playlists (name, ui_order, is_favorite) VALUES (?, -1, ?)",
    undef, $name, $favourite
  );
  my $id = $dbh->sqlite_last_insert_rowid;
  for my $song (@song_ids) {
    $dbh->do(
      "INSERT INTO playlist_items (playlist, type, collection_id, url, title,
         artist) SELECT ?, 2, ROWID, url, title, artist FROM songs
       WHERE ROWID = ?", undef, $id, $song
    );
  }
  $id
}

sub add_loose_item ($dbh, $playlist) {
  $dbh->do(
    "INSERT INTO playlist_items (playlist, type, url, title, artist)
     VALUES (?, 1, 'file:///elsewhere/x.mp3', 'X', 'Y')", undef, $playlist
  );
}

subtest "strawberry database" => sub {
  my $dir  = Path::Tiny->tempdir;
  my $root = "$dir/mp3s";
  my ($dbh, $path) = make_db($dir);
  my ($a, $b, $t) = add_songs($dbh, $root);
  add_song($dbh, $root, "Artist/Album/03 Gone.mp3", "Gone", "Artist", 1);
  my $trance = add_playlist($dbh, "Trance", 1, $a, $b, $a);
  my $chill  = add_playlist($dbh, "Chill",  1, $t);
  add_playlist($dbh, "Playlist 1", 0, $a);
  my $loose = add_playlist($dbh, "Loose", 1);
  $dbh->do(
    "INSERT INTO playlist_items (playlist, type, url, title, artist)
     VALUES (?, 5, 'http://radio.example/stream', 'Radio', 'Net')", undef,
    $loose
  );
  $dbh->do(
    "INSERT INTO songs (url, directory_id) VALUES (?, 1)", undef,
    "file:///elsewhere/y.mp3"
  );
  add_loose_item($dbh, $loose);

  my $songs = PlaylistSync::collection_songs($dbh);
  is [ sort keys %$songs ], [
      "Artist/Album/01 Song A.mp3",
      "Artist/Album/02 Song B.mp3",
      "Other/Album/01 Thé.mp3",
    ],
    "relative paths in NFC, unavailable songs skipped";
  is $songs->{"Artist/Album/01 Song A.mp3"},
    { id => $a, path => "$root/Artist/Album/01 Song A.mp3" },
    "song id and decoded path";
  is $songs->{"Other/Album/01 Thé.mp3"}{path},
    NFD("$root/Other/Album/01 Thé.mp3"),
    "path keeps the form the file system uses";

  is PlaylistSync::strawberry_playlists($dbh), [
      { id => $chill,  name => "Chill" },
      { id => $loose,  name => "Loose" },
      { id => $trance, name => "Trance" },
    ],
    "favourites by name";
  is PlaylistSync::strawberry_items($dbh, $trance), [
      {
        path   => "$root/Artist/Album/01 Song A.mp3",
        rel    => "Artist/Album/01 Song A.mp3",
        title  => "Song A",
        artist => "Artist",
      }, {
        path   => "$root/Artist/Album/02 Song B.mp3",
        rel    => "Artist/Album/02 Song B.mp3",
        title  => "Song B",
        artist => "Artist",
      }, {
        path   => "$root/Artist/Album/01 Song A.mp3",
        rel    => "Artist/Album/01 Song A.mp3",
        title  => "Song A",
        artist => "Artist",
      },
    ],
    "items in order with relative paths";
  is PlaylistSync::strawberry_items($dbh, $chill)->[0]{rel},
    "Other/Album/01 Thé.mp3", "relative path in NFC";
  is PlaylistSync::strawberry_items($dbh, $loose), [
      { path => undef, rel => undef, title => "Radio", artist => "Net" },
      { path => "/elsewhere/x.mp3", rel => undef, title => "X", artist => "Y" },
    ],
    "items outside the collection have no relative path";

  my $ro = PlaylistSync::open_db($path);
  like dies { $ro->do("INSERT INTO playlists (name) VALUES ('x')") },
    qr/readonly/i, "read-only handle rejects writes";
  ok PlaylistSync::open_db($path, 1)->do("DELETE FROM playlists WHERE 0"),
    "writable handle accepts writes";
};

my $Chill_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="2">
  <Track ratingKey="103" playlistItemID="1301" title="Thé"
    grandparentTitle="Other">
    <Media id="3"><Part id="3" file="/srv/music/Other/Album/01 Thé.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="105" playlistItemID="1302" title="Nope"
    grandparentTitle="Other">
    <Media id="5"><Part id="5" file="/srv/music/Other/Album/02 Nope.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="106" playlistItemID="1303" title="Silent"
    grandparentTitle="Other"/>
  </MediaContainer>
  XML

my $Items_later_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="1">
  <Track ratingKey="102" playlistItemID="1002" title="Song B"
    grandparentTitle="Artist">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

sub playlist_rows ($dbh) {
  $dbh->selectall_arrayref(
    "SELECT p.name, p.is_favorite, i.type, i.collection_id, i.title,
       length(i.uuid), i.url
     FROM playlists p LEFT JOIN playlist_items i ON i.playlist = p.ROWID
     ORDER BY p.ROWID, i.ROWID"
  )
}

sub pull_case ($prefix) {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my ($a, $b, $t) = add_songs($dbh, $root, $prefix);
  my $plex = plex({
    "GET /playlists"          => [ ($Playlists_xml) x 4 ],
    "GET /playlists/10/items" => [ $Items_xml, $Items_later_xml, $Items_xml ],
    "GET /playlists/13/items" => [ ($Chill_xml) x 4 ],
  });
  my $mock
    = mock PlaylistSync => (override => [ strawberry_running => sub () { 0 } ]);
  my $url = sub ($rel) { file_url("$root/$prefix$rel") };

  is PlaylistSync::pull_playlists($plex, $dbh, {}), {
      roots     => { plex => "/srv/music/", local => $prefix },
      skipped   => ["Recent"],
      playlists => [
        { name => "Trance", matched => 2, unmatched => [], repeated => 1 },
        {
          name      => "Chill",
          matched   => 1,
          unmatched => [ "Other - Nope", "Other - Silent" ],
        },
      ],
    },
    "summary of the first pull";
  is playlist_rows($dbh), [
      [
        "Trance", 1, 2, $a, "Song A", 36, $url->("Artist/Album/01 Song A.mp3"),
      ], [
        "Trance", 1, 2, $b, "Song B", 36, $url->("Artist/Album/02 Song B.mp3"),
      ],
      [ "Chill", 1, 2, $t, "Thé", 36, $url->(NFD("Other/Album/01 Thé.mp3")) ],
    ],
    "favourite playlists with collection items in Plex order, once each";

  my ($trance_id)
    = $dbh->selectrow_array(
      "SELECT ROWID FROM playlists WHERE name = 'Trance'");
  $dbh->do(
    "UPDATE playlists SET is_favorite = 0 WHERE ROWID = ?", undef,
    $trance_id
  );
  PlaylistSync::pull_playlists($plex, $dbh, { playlists => ["Trance"] });
  is playlist_rows($dbh), [
      [
        "Trance", 1, 2, $b, "Song B", 36, $url->("Artist/Album/02 Song B.mp3"),
      ],
      [ "Chill", 1, 2, $t, "Thé", 36, $url->(NFD("Other/Album/01 Thé.mp3")) ],
    ],
    "second pull replaces the items and restores the favourite flag";
  is $dbh->selectrow_array("SELECT ROWID FROM playlists WHERE name = 'Trance'"),
    $trance_id, "keeps the playlist row";

  PlaylistSync::pull_playlists(
    $plex, $dbh, { dry_run => 1, plex_root => "/srv/music/" }
  );
  is playlist_rows($dbh)->@*, 2, "dry run changes nothing";

  $mock->override(strawberry_running => sub () { 1 });
  like dies { PlaylistSync::pull_playlists($plex, $dbh, {}) },
    qr/Quit Strawberry/, "does not write while Strawberry runs";
}

subtest "pull"                                 => sub { pull_case("") };
subtest "pull into a folder of the collection" => sub { pull_case("t/") };

my $Identity_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer machineIdentifier="abc123"/>
  XML

my $Current_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="3">
  <Track ratingKey="102" playlistItemID="1002" title="Song B"
    grandparentTitle="Artist">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="101" playlistItemID="1001" title="Song A"
    grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="104" playlistItemID="1004" title="Song C"
    grandparentTitle="Artist">
    <Media id="4"><Part id="4" file="/srv/music/Artist/Album/04 Song C.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

my $After_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="3">
  <Track ratingKey="102" playlistItemID="1002" title="Song B"
    grandparentTitle="Artist">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="101" playlistItemID="1001" title="Song A"
    grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="101" playlistItemID="1005" title="Song A"
    grandparentTitle="Artist">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

my $Chill_only_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="1">
  <Track ratingKey="103" playlistItemID="1301" title="Thé"
    grandparentTitle="Other">
    <Media id="3"><Part id="3" file="/srv/music/Other/Album/01 Thé.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

my $Created_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="1">
  <Playlist ratingKey="20" title="New" playlistType="audio" smart="0"/>
  </MediaContainer>
  XML

subtest "push plans" => sub {
  my $current = [
    { item_id => 1002, key => 102 },
    { item_id => 1001, key => 101 },
    { item_id => 1004, key => 104 },
  ];
  is PlaylistSync::plan_changes($current, [ 101, 102, 101 ]),
    { remove => [1004], add => [101] },
    "removes extra items and adds missing ones";
  is PlaylistSync::plan_changes($current, [ 102, 101, 104 ]),
    { remove => [], add => [] }, "nothing to change";
  is PlaylistSync::plan_moves([ 1, 2, 3 ], [ 1, 2, 3 ]), [],
    "already in order";
  is PlaylistSync::plan_moves([ 1, 2, 3 ], [ 3, 1, 2 ]), [ [ 3, undef ] ],
    "one move to the top";
  is PlaylistSync::plan_moves([ 1, 2, 3 ], [ 2, 3, 1 ]),
    [ [ 2, undef ], [ 3, 2 ] ], "moves after the previous item";
  is PlaylistSync::reorder_plan([ { item_id => 1, key => 101 } ],
    [ 102, 101 ]), [], "ignores keys with no item";
};

sub uri_arg ($keys) {
  my $metadata = join ",", @$keys;
  uri_escape_utf8(
    "server://abc123/com.plexapp.plugins.library/library/metadata/$metadata")
}

subtest "push adds without removing" => sub {
  my $after = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <MediaContainer size="2">
    <Track ratingKey="101" playlistItemID="1001" title="Song A"/>
    <Track ratingKey="102" playlistItemID="1002" title="Song B"/>
    </MediaContainer>
    XML
  my $plex = plex({
    "GET /identity"                                 => $Identity_xml,
    "PUT /playlists/10/items?uri=" . uri_arg([102]) => "",
    "GET /playlists/10/items"                       => $after,
  });
  my $current = [ { item_id => 1001, key => 101 } ];
  is PlaylistSync::sync_playlist($plex, 10, $current, [ 101, 102 ], 0),
    { removed => 0, added => 1, moved => 0 }, "adds the missing track";
  is [ grep !/^GET/, $plex->{http}{calls}->@* ],
    [ "PUT /playlists/10/items?uri=" . uri_arg([102]) ], "one add, no removes";
};

subtest "push with nothing matched" => sub {
  my $dir   = Path::Tiny->tempdir;
  my ($dbh) = make_db($dir);
  my $loose = add_playlist($dbh, "Trance", 1);
  add_loose_item($dbh, $loose);
  my $plex = plex({
    "GET /library/sections"               => $Sections_xml,
    "GET /library/sections/1/all?type=10" => $Tracks_xml,
    "GET /playlists"                      => $Playlists_xml,
    "GET /playlists/10/items"             => $Current_xml,
  });
  is PlaylistSync::push_playlists($plex, $dbh, {}), {
      roots     => { plex => undef, local => "" },
      playlists => [ {
        name      => "Trance",
        matched   => 0,
        unmatched => ["Y - X"],
        skipped   => "no tracks matched",
      } ],
    },
    "leaves the Plex playlist alone when nothing matched";
  is [ grep !/^GET/, $plex->{http}{calls}->@* ], [], "sends no changes";
};

sub push_case ($prefix) {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my ($a, $b, $t) = add_songs($dbh, $root, $prefix);
  add_playlist($dbh, "Trance", 1, $a, $b, $a);
  add_playlist($dbh, "New",    1, $b);
  add_playlist($dbh, "Recent", 1, $a);
  add_playlist($dbh, "Chill",  1, $t);
  add_playlist($dbh, "Empty",  1);
  my $loose = add_playlist($dbh, "Loose", 1);
  add_loose_item($dbh, $loose);
  my $responses = {
    "GET /identity"                       => $Identity_xml,
    "GET /library/sections"               => $Sections_xml,
    "GET /library/sections/1/all?type=10" => $Tracks_xml,
    "GET /playlists"                      => $Playlists_xml,
    "GET /playlists/10/items" => [ $Current_xml, $After_xml, $Current_xml ],
    "GET /playlists/13/items" => $Chill_only_xml,
    "DELETE /playlists/10/items/1004"               => "",
    "PUT /playlists/10/items?uri=" . uri_arg([101]) => "",
    "PUT /playlists/10/items/1001/move"             => "",
    "POST /playlists?type=audio&smart=0&title=New&uri="
      . uri_arg([102]) => $Created_xml,
  };

  my $plex = plex($responses);
  is PlaylistSync::push_playlists($plex, $dbh, {}), {
      roots     => { plex => "/srv/music/", local => $prefix },
      playlists => [
        {
          name      => "Chill",
          matched   => 1,
          unmatched => [],
          removed   => 0,
          added     => 0,
          moved     => 0,
        },
        { name => "Empty", matched => 0, unmatched => [], created => 0 },
        {
          name      => "Loose",
          matched   => 0,
          unmatched => ["Y - X"],
          skipped   => "no tracks matched",
        },
        { name => "New", matched => 1, unmatched => [], created => 1 },
        {
          name      => "Recent",
          matched   => 1,
          unmatched => [],
          skipped   => "smart playlist on Plex",
        }, {
          name      => "Trance",
          matched   => 3,
          unmatched => [],
          removed   => 1,
          added     => 1,
          moved     => 1,
        },
      ],
    },
    "summary of the push";
  is [ grep !/^GET/, $plex->{http}{calls}->@* ], [
      "POST /playlists?type=audio&smart=0&title=New&uri=" . uri_arg([102]),
      "DELETE /playlists/10/items/1004",
      "PUT /playlists/10/items?uri=" . uri_arg([101]),
      "PUT /playlists/10/items/1001/move",
    ],
    "creates, removes, adds and moves on Plex";

  $plex->{http}{calls} = [];
  my $summary = PlaylistSync::push_playlists(
    $plex, $dbh, { dry_run => 1, plex_root => "/srv/music/" }
  );
  is [ $summary->{playlists}[5]->@{ qw( removed added moved ) } ], [ 1, 1, 1 ],
    "dry run still counts the changes";
  is [ grep !/^GET/, $plex->{http}{calls}->@* ], [], "dry run changes nothing";
}

subtest "push"                                 => sub { push_case("") };
subtest "push from a folder of the collection" => sub { push_case("t/") };

subtest "formats" => sub {
  is [ PlaylistSync::mp3_for("flac-tagged/A/B/01 X.flac") ],
    ["t/f/A/B/01 X.mp3"], "the MP3 of a FLAC";
  is [ PlaylistSync::mp3_for("flac-tagged/A/B/01 X.mp3") ], [],
    "a FLAC folder needs a FLAC file";
  is [ PlaylistSync::mp3_for("t/f/A/B/01 X.flac") ], [],
    "a FLAC outside its folder";
  is [ PlaylistSync::flac_for("t/f/A/B/01 X.mp3") ],
    ["flac-tagged/A/B/01 X.flac"], "the FLAC of a converted MP3";
  is [ PlaylistSync::flac_for("t/m/A/B/01 X.mp3") ], [],
    "an MP3 with no FLAC";
};

subtest "pull formats" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my ($a)   = add_songs($dbh, $root);
  my $f     = add_song($dbh, $root, "t/f/Artist/Album/03 Song F.mp3", "Song F",
    "Artist");
  my $items = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <MediaContainer size="4">
    <Track ratingKey="101" playlistItemID="1001" title="Song A"
      grandparentTitle="Artist">
      <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
      </Media>
    </Track>
    <Track ratingKey="107" playlistItemID="1007" title="Song F"
      grandparentTitle="Artist">
      <Media id="7"><Part id="7"
        file="/srv/music/flac-tagged/Artist/Album/03 Song F.flac"/></Media>
    </Track>
    <Track ratingKey="108" playlistItemID="1008" title="Song F"
      grandparentTitle="Artist">
      <Media id="8"><Part id="8"
        file="/srv/music/t/f/Artist/Album/03 Song F.mp3"/></Media>
    </Track>
    <Track ratingKey="109" playlistItemID="1009" title="Song G"
      grandparentTitle="Artist">
      <Media id="9"><Part id="9"
        file="/srv/music/flac-tagged/Artist/Album/04 Song G.flac"/></Media>
    </Track>
    </MediaContainer>
    XML
  my $plex = plex({
    "GET /playlists"          => $Playlists_xml,
    "GET /playlists/10/items" => $items,
  });
  my $mock
    = mock PlaylistSync => (override => [ strawberry_running => sub () { 0 } ]);
  is PlaylistSync::pull_playlists($plex, $dbh, { playlists => ["Trance"] }), {
      roots     => { plex => "/srv/music/", local => "" },
      skipped   => [],
      playlists => [ {
        name      => "Trance",
        matched   => 2,
        unmatched => ["Artist - Song G"],
        repeated  => 1,
      } ],
    },
    "maps a FLAC entry to its MP3 and drops the repeat";
  is [ map $_->[3], playlist_rows($dbh)->@* ], [ $a, $f ],
    "the MP3 stands in for the FLAC";
};

subtest "push formats" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my $f     = add_song($dbh, $root, "t/f/Artist/Album/03 Song F.mp3", "Song F",
    "Artist");
  my $m = add_song($dbh, $root, "t/m/Artist/Album/04 Song M.mp3", "Song M",
    "Artist");
  my $g = add_song($dbh, $root, "t/m/Artist/Album/05 Song G.mp3", "Song G",
    "Artist");
  add_playlist($dbh, "Fresh", 1, $f);
  add_playlist($dbh, "Mix",   1, $f, $m, $g);
  add_playlist($dbh, "Old",   1, $f);
  my $flac_f = qq(file="/srv/music/flac-tagged/Artist/Album/03 Song F.flac");
  my $mp3_f  = qq(file="/srv/music/t/f/Artist/Album/03 Song F.mp3");
  my $mp3_m  = qq(file="/srv/music/t/m/Artist/Album/04 Song M.mp3");
  my $tracks = <<~XML;
    <MediaContainer size="3">
    <Track ratingKey="107" title="Song F" grandparentTitle="Artist">
      <Media id="7"><Part id="7" $flac_f/></Media>
    </Track>
    <Track ratingKey="108" title="Song F" grandparentTitle="Artist">
      <Media id="8"><Part id="8" $mp3_f/></Media>
    </Track>
    <Track ratingKey="109" title="Song M" grandparentTitle="Artist">
      <Media id="9"><Part id="9" $mp3_m/></Media>
    </Track>
    </MediaContainer>
    XML
  my $mix = <<~XML;
    <MediaContainer size="2">
    <Track ratingKey="107" playlistItemID="1071" title="Song F"
      grandparentTitle="Artist">
      <Media id="7"><Part id="7" $flac_f/></Media>
    </Track>
    <Track ratingKey="109" playlistItemID="1091" title="Song M"
      grandparentTitle="Artist">
      <Media id="9"><Part id="9" $mp3_m/></Media>
    </Track>
    </MediaContainer>
    XML
  my $old = <<~XML;
    <MediaContainer size="1">
    <Track ratingKey="108" playlistItemID="1081" title="Song F"
      grandparentTitle="Artist">
      <Media id="8"><Part id="8" $mp3_f/></Media>
    </Track>
    </MediaContainer>
    XML
  my $playlists = <<~XML;
    <MediaContainer size="2">
    <Playlist ratingKey="30" title="Mix" playlistType="audio" smart="0"/>
    <Playlist ratingKey="31" title="Old" playlistType="audio" smart="0"/>
    </MediaContainer>
    XML
  my $create = "POST /playlists?type=audio&smart=0&title=Fresh&uri=";
  my $plex   = plex({
    "GET /identity"                       => $Identity_xml,
    "GET /library/sections"               => $Sections_xml,
    "GET /library/sections/1/all?type=10" => $tracks,
    "GET /playlists"                      => $playlists,
    "GET /playlists/30/items"             => $mix,
    "GET /playlists/31/items"             => $old,
    $create . uri_arg([107])              => $Created_xml,
  });
  my $changes = sub (%opts) {
    my $summary
      = PlaylistSync::push_playlists($plex, $dbh, { dry_run => 1, %opts });
    [
      map [ @$_{ qw( name matched removed added ) } ],
      grep $_->{name} ne "Fresh",
      $summary->{playlists}->@*,
    ]
  };
  is $changes->(), [ [ "Mix", 2, 0, 0 ], [ "Old", 1, 0, 0 ] ],
    "keeps the format each Plex entry already has";
  is $changes->(mp3 => 1), [ [ "Mix", 2, 1, 1 ], [ "Old", 1, 0, 0 ] ],
    "--mp3 swaps a FLAC entry for its MP3";
  is $changes->(flac => 1), [ [ "Mix", 2, 0, 0 ], [ "Old", 1, 1, 1 ] ],
    "--flac swaps an MP3 entry for its FLAC";
  PlaylistSync::push_playlists($plex, $dbh, { playlists => ["Fresh"] });
  is [ grep !/^GET/, $plex->{http}{calls}->@* ],
    [ $create . uri_arg([107]) ], "a new playlist takes the FLAC";
};

sub make_file ($path, $content) {
  path($path)->touchpath->spew_raw($content);
}

sub exported_files ($dir) {
  my @files;
  my $next = path($dir)->iterator({ recurse => 1 });
  while (my $p = $next->()) {
    push @files, decode_utf8($p->relative($dir)->stringify) if $p->is_file;
  }
  [ sort @files ]
}

subtest "export" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my $out   = "$dir/out";
  my ($dbh) = make_db($dir);
  my ($a, $b, $t) = add_songs($dbh, $root);
  make_file("$root/$_->[0]", "mp3 $_->[1]") for @$Songs;
  add_playlist($dbh, "Trance",    1, $a, $b, $a);
  add_playlist($dbh, "Chill",     1, $t);
  add_playlist($dbh, "AC/DC mix", 1, $b);
  add_playlist($dbh, "Tab",       0, $a);
  my $loose = add_playlist($dbh, "Loose", 1);
  add_loose_item($dbh, $loose);
  make_file("$out/Artist/Album/01 Song A.mp3", "mp3 Song A");
  make_file("$out/Old/Album/x.mp3",            "stale");
  make_file("$out/Gone.m3u8",                  "#EXTM3U\n");
  make_file("$out/.DS_Store",                  "junk");
  my $kept_mtime = (stat "$out/Artist/Album/01 Song A.mp3")[9];

  is PlaylistSync::export_playlists($dbh, $out, {}), {
      playlists => [
        { name => "AC/DC mix", matched => 1, unmatched => [] },
        { name => "Chill",     matched => 1, unmatched => [] },
        { name => "Loose",     matched => 0, unmatched => ["Y - X"] },
        { name => "Trance",    matched => 3, unmatched => [] },
      ],
      copied  => 2,
      removed => 2,
    },
    "summary of the export";
  is exported_files($out), [
      ".DS_Store",                  "AC_DC mix.m3u8",
      "Artist/Album/01 Song A.mp3", "Artist/Album/02 Song B.mp3",
      "Chill.m3u8",                 "Loose.m3u8",
      "Other/Album/01 Thé.mp3",     "Trance.m3u8",
    ],
    "files once each in NFC, stale files gone, hidden files kept";
  ok !-d "$out/Old", "prunes empty directories";
  is path("$out/Trance.m3u8")->slurp_utf8,
    "#EXTM3U\nArtist/Album/01 Song A.mp3\nArtist/Album/02 Song B.mp3\n"
    . "Artist/Album/01 Song A.mp3\n", "m3u entries relative to the root";
  is path("$out/Other/Album/01 Thé.mp3")->slurp_raw, "mp3 Thé",
    "copies the file content";
  is(
    (stat "$out/Artist/Album/01 Song A.mp3")[9],
    $kept_mtime,
    "leaves an unchanged file alone"
  );

  make_file("$out/Old/Album/x.mp3", "stale");
  is PlaylistSync::export_playlists($dbh, $out, { playlists => ["Trance"] }), {
      playlists => [ { name => "Trance", matched => 3, unmatched => [] } ],
      copied    => 0,
      removed   => 0,
    },
    "a narrowed export skips the cleanup";
  ok -f "$out/Old/Album/x.mp3", "a narrowed export keeps the stale file";

  path("$out/Artist/Album/02 Song B.mp3")->remove;
  my $summary = PlaylistSync::export_playlists($dbh, $out, { dry_run => 1 });
  is [ $summary->@{ qw( copied removed ) } ], [ 1, 1 ],
    "dry run counts the work";
  ok !-f "$out/Artist/Album/02 Song B.mp3", "dry run copies nothing";
  ok -f "$out/Old/Album/x.mp3",             "dry run removes nothing";

  chmod 0555, "$out/Old/Album";
  like dies { PlaylistSync::export_playlists($dbh, $out, {}) },
    qr/Cannot remove/, "a stale file that cannot go stops the export";
  chmod 0755, "$out/Old/Album";
  path("$out/Artist/Album/02 Song B.mp3")->remove;
  chmod 0555, "$out/Artist/Album";
  like dies { PlaylistSync::export_playlists($dbh, $out, {}) },
    qr/Cannot copy/, "a copy that fails stops the export";
  chmod 0755, "$out/Artist/Album";
  my $nowhere
    = PlaylistSync::export_playlists($dbh, "$dir/nowhere", { dry_run => 1 });
  is $nowhere->{removed}, 0, "dry run into a missing folder removes nothing";
  ok !-d "$dir/nowhere", "dry run creates no folder";

  path("$root/Artist/Album/02 Song B.mp3")->remove;
  like dies { PlaylistSync::export_playlists($dbh, $out, {}) },
    qr/Missing file/, "a missing source file stops the export";
  my $locked = "$dir/locked";
  mkdir $locked or die "Cannot make $locked ($!)";
  chmod 0555, $locked;
  like dies { PlaylistSync::export_playlists($dbh, $locked, {}) },
    qr/Cannot write/, "an unwritable folder stops the export";
  chmod 0755, $locked;
};

subtest "options" => sub {
  my $opts = PlaylistSync::parse_options([
    qw( pull --server x --token t --playlist A --playlist B --dry-run ),
    qw( --plex-root /srv/music --user 21 --local-root t --flac ),
  ]);
  is [
    $opts->@{
      qw(
        command server     token playlists dry_run plex_root
        user    local_root flac
      ),
    }
    ],
    [ "pull", "x", "t", [ "A", "B" ], 1, "/srv/music/", 21, "t/", 1 ],
    "parses a command with options";
  like dies { PlaylistSync::parse_options([ qw( push --flac --mp3 ) ]) },
    qr/only one of --flac and --mp3/, "one format at a time";
  like $opts->{db}, qr/strawberry\.db$/, "defaults the database path";
  like dies {
    local $SIG{__WARN__} = sub (@) { };
    PlaylistSync::parse_options(["--bogus"]);
  }, qr/Usage:/, "unknown option shows the usage";
  like dies { PlaylistSync::parse_options([]) }, qr/Usage:/,
    "missing command shows the usage";
  like dies { PlaylistSync::parse_options(["dance"]) }, qr/Usage:/,
    "unknown command shows the usage";
  is [
    PlaylistSync::parse_options(
      [ qw( list --plex-root /srv/ --local-root t/ ) ]
    )->@{ qw( plex_root local_root ) }
    ],
    [ "/srv/", "t/" ], "keeps trailing slashes on the roots";
};

subtest "plex client" => sub {
  my $sign_in = "POST https://plex.tv/users/sign_in.xml";
  my $http    = FakeHttp->new({ $sign_in => qq(<user authToken="secret"/>) });
  like dies { PlaylistSync::plex_client({ server => "http://x" }, $http) },
    qr/--token or --username/, "needs a way to authenticate";
  is PlaylistSync::plex_client(
    { server => "http://x/", token => "t", debug => 1 }, $http
    ),
    { http => $http, server => "http://x", token => "t", debug => 1 },
    "uses a given token and trims the server slash";
  is PlaylistSync::plex_client(
    { server => "http://x", username => "me", password => "pw" }, $http
  )->{token}, "secret", "signs in with a username and password";
  is $http->{calls}, ["$sign_in me"], "posted the sign in form";
  my $mock
    = mock PlaylistSync => (override => [ read_password => sub () { "pw" } ]);
  is PlaylistSync::plex_client({ server => "http://x", username => "me" },
    $http)->{token}, "secret", "prompts for the password";
  $http = FakeHttp->new;
  like dies {
    PlaylistSync::plex_client(
      { server => "http://x", username => "me", password => "pw" }, $http
    )
  }, qr/401 Unauthorized/, "reports a failed sign in";
  $http = FakeHttp->new({ $sign_in => "<user/>" });
  like dies {
    PlaylistSync::plex_client(
      { server => "http://x", username => "me", password => "pw" }, $http
    )
  }, qr/returned no token/, "reports a sign in without a token";
  ok PlaylistSync::plex_client({ server => "http://x", token => "t" })
    ->{http}->isa("HTTP::Tiny"), "builds a real client when none is given";

  my $shared = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <MediaContainer size="2">
    <SharedServer id="1" username="owner"/>
    <SharedServer id="2" userID="21" accessToken="usertok"/>
    </MediaContainer>
    XML
  $http = FakeHttp->new({
    "GET /identity"                          => $Identity_xml,
    "GET /api/servers/abc123/shared_servers" =>
      [ $shared, qq(<MediaContainer size="0"/>) ],
  });
  my $user = PlaylistSync::plex_client(
    { server => "http://x", token => "t", user => 21 }, $http
  );
  is [ @$user{ qw( token machine_id ) } ], [ "usertok", "abc123" ],
    "swaps in the token of the given user";
  like dies {
    PlaylistSync::plex_client(
      { server => "http://x", token => "t", user => 99 }, $http
    )
  }, qr/No access token for Plex user 99/, "unknown user";

  my $resources = "GET /api/v2/resources?includeHttps=1&includeRelay=1";
  my $devices   = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <resources>
    <resource name="Wezflix" provides="server">
    <connections>
    <connection uri="https://lan.plex.direct:32400" local="1" relay="0"/>
    <connection uri="https://wan.plex.direct:32400" local="0" relay="0"/>
    <connection uri="https://relay.plex.direct:8443" local="0" relay="1"/>
    </connections>
    </resource>
    <resource name="shadowfax" provides="server">
    <connections>
    <connection uri="https://lan2.plex.direct:32400" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Wezflix" provides="client,player">
    <connections>
    <connection uri="http://1.2.3.4:1" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Odd"/>
    </resources>
    XML
  $http = FakeHttp->new({ $resources => $devices });
  is PlaylistSync::plex_client({ token => "t" }, $http)->{server},
    "https://wan.plex.direct:32400",
    "finds Wezflix on plex.tv and prefers its direct internet connection";
  is $http->{headers}{"X-Plex-Client-Identifier"}, "playlist_sync",
    "sends the client identifier plex.tv requires";
  is PlaylistSync::plex_client({ token => "t", server => "shadowfax" }, $http)
    ->{server}, "https://lan2.plex.direct:32400",
    "finds a server by name and falls back to a LAN connection";
  like dies {
    PlaylistSync::plex_client({ token => "t", server => "Nope" }, $http)
  }, qr/No Plex server called Nope \(found Wezflix, shadowfax\)/,
    "unknown server name";
  $http = FakeHttp->new({ $resources => <<~XML });
    <resources>
    <resource name="Far" provides="server">
    <connections>
    <connection uri="https://relay.plex.direct:8443" local="0" relay="1"/>
    <connection uri="https://lan.plex.direct:32400" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Off" provides="server"><connections/></resource>
    </resources>
    XML
  is PlaylistSync::plex_client({ token => "t", server => "Far" }, $http)
    ->{server}, "https://lan.plex.direct:32400",
    "prefers a LAN connection over the relay";
  like dies {
    PlaylistSync::plex_client({ token => "t", server => "Off" }, $http)
  }, qr/Plex server Off has no connections/, "server without connections";
  $http = FakeHttp->new({ $resources => "<resources/>" });
  like dies { PlaylistSync::plex_client({ token => "t" }, $http) },
    qr/No Plex server called Wezflix \(found none\)/, "no servers at all";
};

sub capture ($code) {
  my $out = "";
  {
    local *STDOUT;
    open STDOUT, ">:encoding(UTF-8)", \$out or die "Cannot capture STDOUT ($!)";
    $code->();
    close STDOUT or die "Cannot close STDOUT ($!)";
  }
  decode_utf8($out)
}

subtest "run" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my $a
    = add_song($dbh, $root, "Artist/Album/01 Song A.mp3", "Song A", "Artist");
  make_file("$root/Artist/Album/01 Song A.mp3", "mp3 Song A");
  add_playlist($dbh, "Trance", 1, $a, $a);
  add_playlist($dbh, "Tab", 0, $a);
  my $plex = plex({
    "GET /playlists"          => [ ($Playlists_xml) x 3 ],
    "GET /playlists/10/items" => $Items_xml,
    "GET /playlists/13/items" => $Chill_xml,
  });
  my $mock = mock PlaylistSync => (override => [
    plex_client        => sub (@) { $plex },
    open_db            => sub (@) { $dbh },
    strawberry_running => sub () { 0 },
  ]);
  my $run = sub (@argv) {
    capture(sub { PlaylistSync::run(PlaylistSync::parse_options(\@argv)) })
  };

  is $run->(qw( list --server s --token t )),
      "Plex playlists:\n"
    . "  Trance (3 tracks)\n"
    . "  Recent (5 tracks, smart)\n"
    . "  Chill (1 track)\n"
    . "Strawberry playlists:\n"
    . "  Trance (2 tracks)\n", "lists both sides";
  is $run->(qw( pull --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Trance: 1 of 3 tracks (repeated 1)\n"
    . "  not found: Artist - Song B\n"
    . "Chill: 0 of 3 tracks\n"
    . "  not found: Other - Thé\n"
    . "  not found: Other - Nope\n"
    . "  not found: Other - Silent\n"
    . "Skipped smart playlists: Recent\n"
    . "Dry run, nothing changed\n", "reports a pull";
  like dies { $run->(qw( export --server s --token t )) }, qr/--dir/,
    "export needs a folder";
  is $run->("export", "--dir", "$dir/out"),
    "Trance: 2 of 2 tracks\nCopied 1 file, removed 0\n", "reports an export";
};

sub capture_stderr ($code) {
  my $err = "";
  {
    local *STDERR;
    open STDERR, ">:encoding(UTF-8)", \$err or die "Cannot capture STDERR ($!)";
    $code->();
    close STDERR or die "Cannot close STDERR ($!)";
  }
  decode_utf8($err)
}

subtest "edge cases" => sub {
  my $empty = qq(<MediaContainer size="0"/>);
  my $plex  = plex({
    "GET /playlists"                        => $empty,
    "GET /playlists/1/items"                => $empty,
    "GET /library/sections"                 => $empty,
    "GET /identity"                         => $empty,
    "PUT /playlists/1/items/5/move?after=4" => "",
  });
  is PlaylistSync::plex_playlists($plex),         [], "no playlists";
  is PlaylistSync::plex_playlist_items($plex, 1), [], "no items";
  is PlaylistSync::plex_library_tracks($plex),    [], "no music sections";
  like dies { PlaylistSync::plex_machine_id($plex) }, qr/machine identifier/,
    "no identity";
  PlaylistSync::plex_move_item($plex, 1, 5, 4);
  is $plex->{http}{calls}[-1], "PUT /playlists/1/items/5/move?after=4",
    "moves after an item";
  $plex = plex({
    "GET /library/sections"               => $Sections_xml,
    "GET /library/sections/1/all?type=10" => $empty,
  });
  is PlaylistSync::plex_library_tracks($plex), [],  "an empty music section";
  is PlaylistSync::chars(encode_utf8("é")),    "é", "decodes bytes";
  is PlaylistSync::chars(undef),               "",  "empty for undef";

  $plex = plex({
    "GET /playlists" => qq(<MediaContainer size="2">
      <Playlist ratingKey="9" title="Bare" playlistType="audio"/>
      <Playlist ratingKey="8" title="Odd"/>
      </MediaContainer>),
  });
  is PlaylistSync::plex_playlists($plex),
    [ { id => 9, title => "Bare", smart => 0, count => 0 } ],
    "defaults for a playlist without a type or a count";

  $plex = plex({ "GET /identity" => $Identity_xml });
  $plex->{debug} = 1;
  is capture_stderr(sub { PlaylistSync::plex_machine_id($plex) }),
    "GET http://plex.test:32400/identity\n", "debug shows each request";
};

subtest "strawberry running" => sub {
  my $bin   = Path::Tiny->tempdir;
  my $pgrep = path("$bin/pgrep");
  $pgrep->spew("#!/bin/sh\nexit 0\n");
  chmod 0755, $pgrep;
  local $ENV{PATH} = "$bin:$ENV{PATH}";
  ok PlaylistSync::strawberry_running(), "running when pgrep finds it";
  $pgrep->spew("#!/bin/sh\nexit 1\n");
  chmod 0755, $pgrep;
  ok !PlaylistSync::strawberry_running(), "not running otherwise";
};

sub with_terminal ($input, $code) {
  local *STDIN;
  open STDIN,     "<",  \$input     or die "Cannot fake STDIN ($!)";
  open my $saved, ">&", \*STDERR    or die "Cannot save STDERR ($!)";
  open STDERR,    ">",  "/dev/null" or die "Cannot silence STDERR ($!)";
  my $result = $code->();
  open STDERR, ">&", $saved or die "Cannot restore STDERR ($!)";
  $result
}

subtest "password prompt" => sub {
  my $password;
  my $out = with_terminal(
    "secret\n",
    sub {
      capture(sub { $password = PlaylistSync::read_password() })
    }
  );
  is $password, "secret", "reads the password";
  like $out, qr/Plex password:/, "prompts for it";
  with_terminal(
    "",
    sub {
      capture(sub { $password = PlaylistSync::read_password() })
    }
  );
  is $password, "", "empty password at the end of input";
};

subtest "main" => sub {
  my $plex  = plex({ "GET /playlists" => $Playlists_xml });
  my ($dbh) = make_db(Path::Tiny->tempdir);
  my $mock  = mock PlaylistSync => (override => [
    plex_client => sub (@) { $plex }, open_db => sub (@) { $dbh }, ]);
  local @ARGV = qw( list --server s --token t );
  like capture(sub { PlaylistSync::main() }), qr/^Plex playlists:/,
    "runs the command from the arguments";
  local @ARGV = ("--help");
  like capture(sub { PlaylistSync::main() }), qr/^Usage:/, "shows the usage";
};

subtest "report notes" => sub {
  my $summary = {
    playlists => [
      { name => "New",   matched => 1, unmatched => [],        created => 1 },
      { name => "Loose", matched => 0, unmatched => ["Y - X"], created => 0 },
      {
        name      => "Recent",
        matched   => 1,
        unmatched => [],
        skipped   => "smart playlist on Plex",
      }, {
        name      => "Trance",
        matched   => 3,
        unmatched => [],
        removed   => 1,
        added     => 2,
        moved     => 0,
      },
      { name => "Dup", matched => 2, unmatched => [], repeated => 1 },
    ],
  };
  is capture(sub { PlaylistSync::report($summary, {}) }),
      "New: 1 of 1 track (created on Plex)\n"
    . "Loose: 0 of 1 track (not on Plex, nothing to create)\n"
    . "  not found: Y - X\n"
    . "Recent: 1 of 1 track (skipped, smart playlist on Plex)\n"
    . "Trance: 3 of 3 tracks (removed 1, added 2, moved 0)\n"
    . "Dup: 2 of 3 tracks (repeated 1)\n", "notes for each kind of change";
  is capture(sub {
    PlaylistSync::report(
      { roots => { plex => "/m/", local => "t/" }, playlists => [] }, {}
    )
    }),
    "Plex root /m/ maps to collection folder t/\n", "roots with a folder";
  is capture(sub {
    PlaylistSync::report(
      { roots => { plex => undef, local => "" }, playlists => [] }, {}
    )
    }),
    "No Plex root found, so nothing can match\n", "no roots";
};

subtest "default database" => sub {
  local $^O = "darwin";
  like PlaylistSync::default_db(),
    qr{Library/Application Support/strawberry}, "macOS path";
  local $^O = "linux";
  like PlaylistSync::default_db(), qr{\.local/share/strawberry}, "Linux path";
};

done_testing;

__END__

=head1 NAME

playlist_sync.t - tests for utils/playlist_sync

=head1 SYNOPSIS

 yath test t/playlist_sync.t

=head1 DESCRIPTION

Drives the script through its functions with a fake HTTP client in place of
the Plex server and a temporary database built from the Strawberry schema in
F<t/data/strawberry_schema.sql>. The phone and the watch are not involved.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
