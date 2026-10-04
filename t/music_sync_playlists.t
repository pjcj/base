#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use Encode  qw( decode_utf8 );
use FindBin ();
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Path::Tiny         qw( path );
use Test2::V0          qw( dies done_testing is like mock ok subtest );
use Unicode::Normalize qw( NFD );
use URI::Escape        qw( uri_escape_utf8 );

use MusicSync::Playlists qw(
  export_playlists plan_changes plan_moves pull_playlists
  push_playlists   reorder_plan report     sync_playlist
);
use MusicSync::Test qw(
  add_loose_item add_playlist add_song  add_songs
  capture        chill_xml    file_url  identity_xml
  items_xml      make_db      make_file playlists_xml
  plex           sections_xml songs     tracks_xml
);

no warnings "experimental::signatures";

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
    "GET /playlists"          => [ (playlists_xml()) x 4 ],
    "GET /playlists/10/items" =>
      [ items_xml(), $Items_later_xml, items_xml() ],
    "GET /playlists/13/items" => [ (chill_xml()) x 4 ],
  });
  my $mock = mock "MusicSync::Playlists" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  my $url = sub ($rel) { file_url("$root/$prefix$rel") };

  is pull_playlists($plex, $dbh, {}), {
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
  pull_playlists($plex, $dbh, { playlists => ["Trance"] });
  is playlist_rows($dbh), [
      [
        "Trance", 1, 2, $b, "Song B", 36, $url->("Artist/Album/02 Song B.mp3"),
      ],
      [ "Chill", 1, 2, $t, "Thé", 36, $url->(NFD("Other/Album/01 Thé.mp3")) ],
    ],
    "second pull replaces the items and restores the favourite flag";
  is $dbh->selectrow_array("SELECT ROWID FROM playlists WHERE name = 'Trance'"),
    $trance_id, "keeps the playlist row";

  pull_playlists($plex, $dbh, { dry_run => 1, plex_root => "/srv/music/" });
  is playlist_rows($dbh)->@*, 2, "dry run changes nothing";

  $mock->override(strawberry_running => sub () { 1 });
  like dies { pull_playlists($plex, $dbh, {}) }, qr/Quit Strawberry/,
    "does not write while Strawberry runs";
}

subtest "pull" => sub { pull_case("") };

subtest "pull into a folder of the collection" => sub { pull_case("t/") };

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
  is plan_changes($current, [ 101, 102, 101 ]),
    { remove => [1004], add => [101] },
    "removes extra items and adds missing ones";
  is plan_changes($current, [ 102, 101, 104 ]), { remove => [], add => [] },
    "nothing to change";
  is plan_moves([ 1, 2, 3 ], [ 1, 2, 3 ]), [], "already in order";
  is plan_moves([ 1, 2, 3 ], [ 3, 1, 2 ]), [ [ 3, undef ] ],
    "one move to the top";
  is plan_moves([ 1, 2, 3 ], [ 2, 3, 1 ]), [ [ 2, undef ], [ 3, 2 ] ],
    "moves after the previous item";
  is reorder_plan([ { item_id => 1, key => 101 } ], [ 102, 101 ]), [],
    "ignores keys with no item";
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
    "GET /identity"                                 => identity_xml(),
    "PUT /playlists/10/items?uri=" . uri_arg([102]) => "",
    "GET /playlists/10/items"                       => $after,
  });
  my $current = [ { item_id => 1001, key => 101 } ];
  is sync_playlist($plex, 10, $current, [ 101, 102 ], 0),
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
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => tracks_xml(),
    "GET /playlists"                      => playlists_xml(),
    "GET /playlists/10/items"             => $Current_xml,
  });
  is push_playlists($plex, $dbh, {}), {
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

subtest "push section" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my ($a)   = add_songs($dbh, $root);
  add_playlist($dbh, "Trance", 1, $a);
  my $plex = plex({
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/3/all?type=10" => tracks_xml(),
    "GET /playlists"                      => playlists_xml(),
    "GET /playlists/10/items"             => $Current_xml,
  });
  my $summary
    = push_playlists($plex, $dbh, { dry_run => 1, section => "flac" });
  is $summary->{playlists}[0]{matched}, 1,
    "matches against the named section";
  is [ grep m|/library/|, $plex->{http}{calls}->@* ],
    [ "GET /library/sections", "GET /library/sections/3/all?type=10" ],
    "reads only the named section";
  like dies { push_playlists($plex, $dbh, { section => "Nope" }) },
    qr/No Plex music section called Nope \(found mp3, flac\)/,
    "an unknown section stops the push";
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
    "GET /identity"                       => identity_xml(),
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => tracks_xml(),
    "GET /playlists"                      => playlists_xml(),
    "GET /playlists/10/items" => [ $Current_xml, $After_xml, $Current_xml ],
    "GET /playlists/13/items" => $Chill_only_xml,
    "DELETE /playlists/10/items/1004"               => "",
    "PUT /playlists/10/items?uri=" . uri_arg([101]) => "",
    "PUT /playlists/10/items/1001/move"             => "",
    "POST /playlists?type=audio&smart=0&title=New&uri="
      . uri_arg([102]) => $Created_xml,
  };

  my $plex = plex($responses);
  is push_playlists($plex, $dbh, {}), {
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
  my $summary
    = push_playlists($plex, $dbh, { dry_run => 1, plex_root => "/srv/music/" });
  is [ $summary->{playlists}[5]->@{ qw( removed added moved ) } ], [ 1, 1, 1 ],
    "dry run still counts the changes";
  is [ grep !/^GET/, $plex->{http}{calls}->@* ], [], "dry run changes nothing";
}

subtest "push" => sub { push_case("") };

subtest "push from a folder of the collection" => sub { push_case("t/") };

subtest "pull smart playlists" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my ($dbh) = make_db($dir);
  my ($a, $b) = add_songs($dbh, $root);
  my $plex = plex({
    "GET /playlists"          => playlists_xml(),
    "GET /playlists/10/items" => items_xml(),
    "GET /playlists/12/items" => $Items_later_xml,
    "GET /playlists/13/items" => chill_xml(),
  });
  my $mock = mock "MusicSync::Playlists" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is pull_playlists($plex, $dbh, { smart => 1 }), {
      roots     => { plex => "/srv/music/", local => "" },
      skipped   => [],
      playlists => [
        { name => "Trance", matched => 2, unmatched => [], repeated => 1 },
        { name => "Recent", matched => 1, unmatched => [], smart    => 1 },
        {
          name      => "Chill",
          matched   => 1,
          unmatched => [ "Other - Nope", "Other - Silent" ],
        },
      ],
    },
    "pulls smart playlists as snapshots";
  is [ grep $_->[0] eq "Recent", playlist_rows($dbh)->@* ],
    [ [
      "Recent", 1, 2, $b, "Song B", 36,
      file_url("$root/Artist/Album/02 Song B.mp3"),
    ] ],
    "writes the snapshot as a plain favourite";
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
    "GET /playlists"          => playlists_xml(),
    "GET /playlists/10/items" => $items,
  });
  my $mock = mock "MusicSync::Playlists" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is pull_playlists($plex, $dbh, { playlists => ["Trance"] }), {
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
    "GET /identity"                       => identity_xml(),
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => $tracks,
    "GET /playlists"                      => $playlists,
    "GET /playlists/30/items"             => $mix,
    "GET /playlists/31/items"             => $old,
    $create . uri_arg([107])              => $Created_xml,
  });
  my $changes = sub (%opts) {
    my $summary = push_playlists($plex, $dbh, { dry_run => 1, %opts });
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
  push_playlists($plex, $dbh, { playlists => ["Fresh"] });
  is [ grep !/^GET/, $plex->{http}{calls}->@* ],
    [ $create . uri_arg([107]) ], "a new playlist takes the FLAC";
};

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
  make_file("$root/$_->[0]", "mp3 $_->[1]") for songs()->@*;
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

  is export_playlists($dbh, $out, {}), {
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
  is path("$out/Chill.m3u8")->slurp_utf8,
    "#EXTM3U\nOther/Album/01 Thé.mp3\n", "m3u entries written as UTF-8";
  is path("$out/Other/Album/01 Thé.mp3")->slurp_raw, "mp3 Thé",
    "copies the file content";
  is(
    (stat "$out/Artist/Album/01 Song A.mp3")[9],
    $kept_mtime,
    "leaves an unchanged file alone"
  );

  make_file("$out/Old/Album/x.mp3", "stale");
  is export_playlists($dbh, $out, { playlists => ["Trance"] }), {
      playlists => [ { name => "Trance", matched => 3, unmatched => [] } ],
      copied    => 0,
      removed   => 0,
    },
    "a narrowed export skips the cleanup";
  ok -f "$out/Old/Album/x.mp3", "a narrowed export keeps the stale file";

  path("$out/Artist/Album/02 Song B.mp3")->remove;
  my $summary = export_playlists($dbh, $out, { dry_run => 1 });
  is [ $summary->@{ qw( copied removed ) } ], [ 1, 1 ],
    "dry run counts the work";
  ok !-f "$out/Artist/Album/02 Song B.mp3", "dry run copies nothing";
  ok -f "$out/Old/Album/x.mp3",             "dry run removes nothing";

  chmod 0555, "$out/Old/Album";
  like dies { export_playlists($dbh, $out, {}) }, qr/Cannot remove/,
    "a stale file that cannot go stops the export";
  chmod 0755, "$out/Old/Album";
  path("$out/Artist/Album/02 Song B.mp3")->remove;
  chmod 0555, "$out/Artist/Album";
  like dies { export_playlists($dbh, $out, {}) }, qr/Cannot copy/,
    "a copy that fails stops the export";
  chmod 0755, "$out/Artist/Album";
  my $nowhere = export_playlists($dbh, "$dir/nowhere", { dry_run => 1 });
  is $nowhere->{removed}, 0, "dry run into a missing folder removes nothing";
  ok !-d "$dir/nowhere", "dry run creates no folder";

  path("$root/Artist/Album/02 Song B.mp3")->remove;
  like dies { export_playlists($dbh, $out, {}) }, qr/Missing file/,
    "a missing source file stops the export";
  my $locked = "$dir/locked";
  mkdir $locked or die "Cannot make $locked ($!)";
  chmod 0555, $locked;
  like dies { export_playlists($dbh, $locked, {}) }, qr/Cannot write/,
    "an unwritable folder stops the export";
  chmod 0755, $locked;
};

subtest "export smart playlists" => sub {
  my $dir   = Path::Tiny->tempdir;
  my $root  = "$dir/mp3s";
  my $out   = "$dir/out";
  my ($dbh) = make_db($dir);
  my ($a, $b) = add_songs($dbh, $root);
  make_file("$root/Artist/Album/01 Song A.mp3", "mp3 Song A");
  make_file("$root/Artist/Album/02 Song B.mp3", "mp3 Song B");
  add_playlist($dbh, "Trance", 1, $a, $b);
  add_playlist($dbh, "Recent", 1, $a);
  my $plex = plex({
    "GET /playlists"          => playlists_xml(),
    "GET /playlists/12/items" => items_xml(),
  });
  is export_playlists($dbh, $out, {}, $plex), {
      roots     => { plex => "/srv/music/", local => "" },
      playlists => [
        { name => "Recent", matched => 1, unmatched => [] },
        { name => "Trance", matched => 2, unmatched => [] },
        { name => "Recent", matched => 3, unmatched => [], smart => 1 },
      ],
      copied  => 2,
      removed => 0,
    },
    "smart playlists from Plex follow the favourites";
  is $plex->{http}{calls}, [ "GET /playlists", "GET /playlists/12/items" ],
    "reads only the smart playlists";
  is path("$out/Recent.m3u8")->slurp_utf8,
    "#EXTM3U\nArtist/Album/01 Song A.mp3\nArtist/Album/02 Song B.mp3\n"
    . "Artist/Album/01 Song A.mp3\n",
    "the smart playlist replaces the favourite of the same name";
  my $none  = plex({ "GET /playlists" => qq(<MediaContainer size="0"/>) });
  my $plain = export_playlists($dbh, $out, { dry_run => 1 }, $none);
  ok !exists $plain->{roots}, "no roots when Plex has no smart playlists";
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
      {
        name      => "Snap",
        matched   => 2,
        unmatched => [],
        smart     => 1,
        repeated  => 1,
      },
    ],
  };
  is capture(sub { report($summary, {}) }),
      "New: 1 of 1 track (created on Plex)\n"
    . "Loose: 0 of 1 track (not on Plex, nothing to create)\n"
    . "  not found: Y - X\n"
    . "Recent: 1 of 1 track (skipped, smart playlist on Plex)\n"
    . "Trance: 3 of 3 tracks (removed 1, added 2, moved 0)\n"
    . "Dup: 2 of 3 tracks (repeated 1)\n"
    . "Snap: 2 of 3 tracks (smart, repeated 1)\n",
    "notes for each kind of change";
  is capture(sub {
    report({ roots => { plex => "/m/", local => "t/" }, playlists => [] }, {})
    }),
    "Plex root /m/ maps to collection folder t/\n", "roots with a folder";
  is capture(sub {
    report({ roots => { plex => undef, local => "" }, playlists => [] }, {})
    }),
    "No Plex root found, so nothing can match\n", "no roots";
};

done_testing;

__END__

=head1 NAME

music_sync_playlists.t - tests for lib/MusicSync/Playlists.pm

=head1 SYNOPSIS

 yath test t/music_sync_playlists.t

=head1 DESCRIPTION

Pulls, pushes and exports playlists between a fake Plex server and a
temporary Strawberry database. The phone and the watch are not involved.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
