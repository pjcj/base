#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use FindBin ();
use lib "$FindBin::Bin/lib";
use Path::Tiny qw( path );
use Test2::V0  qw( dies done_testing is like mock subtest );

use MusicSync::Test qw(
  add_playlist add_song      albums_xml capture
  chill_xml    dupes_xml     items_xml  make_db
  make_file    playlists_xml plex       sections_xml
  tracks_xml
);

no warnings "experimental::signatures";

my $Base = path($FindBin::Bin)->parent;

sub load_script () {
  do "$Base/utils/music_sync" or die "Cannot load the script ($@$!)";
}

load_script();

subtest "options" => sub {
  my $opts = MusicSync::parse_options([
    qw( playlists pull        --server x --token t --playlist A --playlist B ),
    qw( --dry-run --plex-root /srv/music --user 21 --local-root t --flac ),
    qw( --section s           --smart    --overwrite ),
  ]);
  is [
    $opts->@{
      qw(
        noun      verb server     token playlists dry_run
        plex_root user local_root flac  section   smart
        overwrite
      ),
    }
    ], [
      "playlists", "pull", "x", "t", [ "A", "B" ],
      1, "/srv/music/", 21, "t/", 1, "s", 1, 1,
    ],
    "parses a command with options";
  like
    dies { MusicSync::parse_options([ qw( playlists push --flac --mp3 ) ]) },
    qr/only one of --flac and --mp3/, "one format at a time";
  like dies { MusicSync::parse_options([ qw( ratings merge --overwrite ) ]) },
    qr/merge takes no --overwrite/, "merge has no overwrite";
  like $opts->{db}, qr/strawberry\.db$/, "defaults the database path";
  like dies {
    local $SIG{__WARN__} = sub (@) { };
    MusicSync::parse_options(["--bogus"]);
  }, qr/Usage:/, "unknown option shows the usage";
  like dies { MusicSync::parse_options([]) }, qr/Usage:/,
    "missing noun shows the usage";
  like dies { MusicSync::parse_options([ qw( dance pull ) ]) }, qr/Usage:/,
    "unknown noun shows the usage";
  like dies { MusicSync::parse_options(["playlists"]) }, qr/Usage:/,
    "missing verb shows the usage";
  like dies { MusicSync::parse_options([ qw( playlists dance ) ]) },
    qr/Usage:/, "unknown verb shows the usage";
  is [
    MusicSync::parse_options(
      [ qw( playlists list --plex-root /srv/ --local-root t/ ) ]
    )->@{ qw( plex_root local_root ) }
    ],
    [ "/srv/", "t/" ], "keeps trailing slashes on the roots";
};

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
    "GET /playlists"                      => [ (playlists_xml()) x 3 ],
    "GET /playlists/10/items"             => items_xml(),
    "GET /playlists/12/items"             => items_xml(),
    "GET /playlists/13/items"             => chill_xml(),
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => tracks_xml(),
  });
  my $mock = mock MusicSync => (override => [
    plex_client => sub (@) { $plex }, open_db => sub (@) { $dbh }, ]);
  my $quiet = mock "MusicSync::Playlists" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  my $still = mock "MusicSync::Ratings" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  my $run = sub (@argv) {
    capture(sub { MusicSync::run(MusicSync::parse_options(\@argv)) })
  };

  is $run->(qw( playlists list --server s --token t )),
      "Plex playlists:\n"
    . "  Trance (3 tracks)\n"
    . "  Recent (5 tracks, smart)\n"
    . "  Chill (1 track)\n"
    . "Strawberry playlists:\n"
    . "  Trance (2 tracks)\n", "lists both sides";
  is $run->(qw( playlists pull --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Trance: 1 of 3 tracks (repeated 1)\n"
    . "  not found: Artist - Song B\n"
    . "Chill: 0 of 3 tracks\n"
    . "  not found: Other - Thé\n"
    . "  not found: Other - Nope\n"
    . "  not found: Other - Silent\n"
    . "Skipped smart playlists: Recent\n"
    . "Dry run, nothing changed\n", "reports a pull";
  like dies { $run->(qw( playlists export --server s --token t )) },
    qr/--dir/, "export needs a folder";
  is $run->("playlists", "export", "--dir", "$dir/out"),
    "Trance: 2 of 2 tracks\nCopied 1 file, removed 0\n", "reports an export";
  is $run->("playlists", "export", "--dir", "$dir/out", "--smart"),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Trance: 2 of 2 tracks\n"
    . "Recent: 2 of 3 tracks (smart)\n"
    . "  not found: Artist - Song B\n"
    . "Copied 0 files, removed 0\n", "exports smart playlists from Plex";
  is $run->(qw( ratings pull --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Ratings: 1 to Strawberry, 0 to Plex, 0 unchanged, 2 unmatched\n"
    . "Dry run, nothing changed\n", "reports a ratings pull";
  is $run->(qw( ratings push --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Ratings: 0 to Strawberry, 0 to Plex, 1 unchanged, 2 unmatched\n"
    . "Dry run, nothing changed\n", "reports a ratings push";
  is $run->(qw( ratings merge --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Ratings: 1 to Strawberry, 0 to Plex, 0 unchanged, 2 unmatched\n"
    . "Dry run, nothing changed\n", "reports a ratings merge";
};

subtest "duplicates" => sub {
  my $dir = Path::Tiny->tempdir;
  my ($dbh) = make_db($dir);
  add_song(
    $dbh,     "$dir/mp3s", "t/f/Artist/Album/01 Song A.mp3",
    "Song A", "Artist"
  );
  my $plex = plex({
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => dupes_xml(),
    "GET /library/sections/1/all?type=9"  => albums_xml(),
  });
  my $mock = mock MusicSync => (override => [
    plex_client => sub (@) { $plex }, open_db => sub (@) { $dbh }, ]);
  my $run = sub (@argv) {
    capture(sub { MusicSync::run(MusicSync::parse_options(\@argv)) })
  };
  like $run->(qw( duplicates list --server s --token t )),
    qr/^Plex root .*^Groups: 4, 2 clean, 2 in doubt, 1 folder duplicate$/ms,
    "lists the duplicates";
  my $quiet = mock "MusicSync::Duplicates" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is $run->(qw( duplicates mark --server s --token t --dry-run )),
      "Plex root /srv/music/ maps to the collection root\n"
    . "Losers: 0 marked, 0 already one star, 2 with no local song\n"
    . "Groups in doubt left alone: 2\n"
    . "Dry run, nothing changed\n", "reports a dry mark";
  like MusicSync::usage(), qr/duplicates list.*duplicates mark/s,
    "the usage names both verbs";
};

subtest "main" => sub {
  my $plex  = plex({ "GET /playlists" => playlists_xml() });
  my ($dbh) = make_db(Path::Tiny->tempdir);
  my $mock  = mock MusicSync => (override => [
    plex_client => sub (@) { $plex }, open_db => sub (@) { $dbh }, ]);
  local @ARGV = qw( playlists list --server s --token t );
  like capture(sub { MusicSync::main() }), qr/^Plex playlists:/,
    "runs the command from the arguments";
  local @ARGV = ("--help");
  like capture(sub { MusicSync::main() }), qr/^Usage:/, "shows the usage";
};

done_testing;

__END__

=head1 NAME

music_sync.t - tests for utils/music_sync

=head1 SYNOPSIS

 yath test t/music_sync.t

=head1 DESCRIPTION

Checks the command line and the dispatch of the script, with the Plex client
and the database replaced by fakes.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
