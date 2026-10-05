package MusicSync::Test;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use DBI                ();
use Encode             qw( decode_utf8 );
use Exporter           qw( import );
use FindBin            ();
use Path::Tiny         qw( path );
use Unicode::Normalize qw( NFD );
use URI::Escape        qw( uri_escape_utf8 );

use FakeHttp ();

our @EXPORT_OK = qw(
  add_loose_item add_playlist add_song  add_songs
  albums_xml     capture      chill_xml file_url
  identity_xml   items_xml    make_db   make_file
  playlists_xml  plex         rate_song sections_xml
  songs          tracks_xml
);

sub playlists_xml () {
  <<~XML
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
}

sub items_xml () {
  <<~XML
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
}

sub sections_xml () {
  <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="3">
  <Directory key="1" type="artist" title="mp3"/>
  <Directory key="2" type="movie" title="Films"/>
  <Directory key="3" type="artist" title="flac"/>
  </MediaContainer>
  XML
}

sub tracks_xml () {
  <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Track ratingKey="101" guid="plex://track/a1" parentRatingKey="201"
    title="Song A" grandparentTitle="Artist" duration="180000"
    userRating="8">
    <Media id="1" bitrate="320" duration="180000">
    <Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3" size="7200000"/>
    </Media>
  </Track>
  <Track ratingKey="102" guid="plex://track/b2" parentRatingKey="201"
    title="Song B" grandparentTitle="Artist"
    originalTitle="Artist feat. Guest">
    <Media id="2" bitrate="192" duration="200000">
    <Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3" size="4800000"/>
    </Media>
  </Track>
  <Track ratingKey="103" title="Thé" grandparentTitle="Other">
    <Media id="3"><Part id="3" file="/srv/music/Other/Album/01 Thé.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="104" title="No file" grandparentTitle="Other"/>
  </MediaContainer>
  XML
}

sub albums_xml () {
  <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Directory ratingKey="201" type="album" title="Album" parentTitle="Artist"
    year="1985">
    <Format tag="Album"/>
  </Directory>
  <Directory ratingKey="202" type="album" title="Best Of" parentTitle="Artist"
    year="1999">
    <Format tag="Album"/><Subformat tag="Compilation"/>
  </Directory>
  <Directory ratingKey="203" type="album" title="Hits"
    parentTitle="Various Artists" year="2001">
    <Format tag="Album"/><Subformat tag="Compilation"/><Subformat tag="DJ Mix"/>
  </Directory>
  <Directory ratingKey="204" type="album" title="Undated" parentTitle="Other"/>
  </MediaContainer>
  XML
}

sub identity_xml () {
  <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer machineIdentifier="abc123"/>
  XML
}

sub chill_xml () {
  <<~XML
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
}

sub plex ($responses = {}) {
  my $http = FakeHttp->new($responses);
  { http => $http, server => "http://plex.test:32400", token => "tok" }
}

sub make_db ($dir) {
  my $path = "$dir/strawberry.db";
  my $dbh  = DBI->connect(
    "dbi:SQLite:dbname=$path", "", "",
    { RaiseError => 1, sqlite_unicode => 1 }
  );
  my $schema = path("$FindBin::Bin/data/strawberry_schema.sql")->slurp_utf8;
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

sub rate_song ($dbh, $id, $rating) {
  $dbh->do("UPDATE songs SET rating = ? WHERE ROWID = ?", undef, $rating, $id);
}

my $Songs = [
  [ "Artist/Album/01 Song A.mp3",  "Song A", "Artist" ],
  [ "Artist/Album/02 Song B.mp3",  "Song B", "Artist" ],
  [ NFD("Other/Album/01 Thé.mp3"), "Thé",    "Other" ],
];

sub songs () { $Songs }

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

sub make_file ($path, $content) {
  path($path)->touchpath->spew_raw($content);
}

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

1;

__END__

=head1 NAME

MusicSync::Test - fixtures and helpers for the music_sync tests

=head1 SYNOPSIS

 use MusicSync::Test qw( make_db plex playlists_xml );

=head1 DESCRIPTION

Builds a temporary Strawberry database from the schema in
F<t/data/strawberry_schema.sql>, fills it with songs and playlists, and
hands out Plex clients backed by L<FakeHttp> with canned XML responses.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
