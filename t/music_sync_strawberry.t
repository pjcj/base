#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use open qw( :std :utf8 );

use FindBin ();
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Path::Tiny         qw( path );
use Test2::V0          qw( dies done_testing is like ok subtest );
use Unicode::Normalize qw( NFD );

use MusicSync::Strawberry qw(
  collection_songs     default_db
  open_db              strawberry_items
  strawberry_playlists strawberry_running
);
use MusicSync::Test qw( add_loose_item add_playlist add_song add_songs make_db
);

ok $INC{"DBD/SQLite.pm"}, "the module loads DBD::SQLite itself";

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

  my $songs = collection_songs($dbh);
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

  is strawberry_playlists($dbh), [
      { id => $chill,  name => "Chill" },
      { id => $loose,  name => "Loose" },
      { id => $trance, name => "Trance" },
    ],
    "favourites by name";
  is strawberry_items($dbh, $trance), [
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
  is strawberry_items($dbh, $chill)->[0]{rel}, "Other/Album/01 Thé.mp3",
    "relative path in NFC";
  is strawberry_items($dbh, $loose), [
      { path => undef, rel => undef, title => "Radio", artist => "Net" },
      { path => "/elsewhere/x.mp3", rel => undef, title => "X", artist => "Y" },
    ],
    "items outside the collection have no relative path";

  my $ro = open_db($path);
  like dies { $ro->do("INSERT INTO playlists (name) VALUES ('x')") },
    qr/readonly/i, "read-only handle rejects writes";
  ok open_db($path, 1)->do("DELETE FROM playlists WHERE 0"),
    "writable handle accepts writes";
};

subtest "strawberry running" => sub {
  my $bin   = Path::Tiny->tempdir;
  my $pgrep = path("$bin/pgrep");
  $pgrep->spew("#!/bin/sh\nexit 0\n");
  chmod 0755, $pgrep;
  local $ENV{PATH} = "$bin:$ENV{PATH}";
  ok strawberry_running(), "running when pgrep finds it";
  $pgrep->spew("#!/bin/sh\nexit 1\n");
  chmod 0755, $pgrep;
  ok !strawberry_running(), "not running otherwise";
};

subtest "default database" => sub {
  local $^O = "darwin";
  like default_db(), qr{Library/Application Support/strawberry}, "macOS path";
  local $^O = "linux";
  like default_db(), qr{\.local/share/strawberry}, "Linux path";
};

done_testing;

__END__

=head1 NAME

music_sync_strawberry.t - tests for lib/MusicSync/Strawberry.pm

=head1 SYNOPSIS

 yath test t/music_sync_strawberry.t

=head1 DESCRIPTION

Works on a temporary database built from the Strawberry schema in
F<t/data/strawberry_schema.sql>.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
