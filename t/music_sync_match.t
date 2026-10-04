#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use open qw( :std :utf8 );

use FindBin ();
use lib "$FindBin::Bin/../lib";
use Test2::V0 qw( done_testing is subtest );

use MusicSync::Match qw( detect_roots flac_for local_rel mp3_for plex_rel roots
);

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
  is detect_roots($tracks, $local), { plex => "/srv/music/", local => "t/" },
    "roots from a track found locally";
  is detect_roots(
    [
      { key => 6, path => "/srv/music/Cover/Cover/01 Song A.mp3" },
      $tracks->[2],
    ],
    $local
    ),
    { plex => "/srv/music/", local => "t/" },
    "a deeper match beats an earlier name-only match";
  is detect_roots(
    [ $tracks->[2] ],
    { "Other/Album/01 Song A.mp3" => 1, "t/Artist/Album/01 Song A.mp3" => 1 }
    ),
    { plex => "/srv/music/", local => "t/" },
    "the deeper of two local files with one name wins";
  is detect_roots(
    [ { key => 4, path => "/srv/music/Artist/Album/02 Song B.mp3" } ], $local
    ),
    { plex => "/srv/music/", local => "" },
    "a collection that mirrors the library directly";
  is detect_roots([ $tracks->[1] ], $local), undef,
    "undef when nothing matches";
  is detect_roots([ { key => 5, path => "x.mp3" } ], { "x.mp3" => 1 }),
    { plex => "/", local => "" }, "a bare file name on both sides";
  is roots({ plex_root => "/x/", local_root => "y/" }, [], $local),
    { plex => "/x/", local => "y/" }, "options override detection";
  is roots({}, [], $local), { plex => undef, local => "" },
    "no roots without a match";
  is plex_rel("/srv/", "/srv/a.mp3"),   "a.mp3", "path under the root";
  is plex_rel("/srv/", "/other/a.mp3"), undef,   "path outside the root";
  is plex_rel(undef, "/srv/a.mp3"),     undef,   "no root known";
  is plex_rel("/srv/", undef),          undef,   "track without a file";
  is local_rel("t/", "t/a.mp3"),        "a.mp3", "path under the folder";
  is local_rel("t/", "u/a.mp3"),        undef,   "path outside the folder";
  is local_rel("", "a.mp3"),            "a.mp3", "no folder prefix";
  is local_rel("t/", undef),            undef,   "item without a path";
};

subtest "formats" => sub {
  is [ mp3_for("flac-tagged/A/B/01 X.flac") ], ["t/f/A/B/01 X.mp3"],
    "the MP3 of a FLAC";
  is [ mp3_for("flac-tagged/A/B/01 X.mp3") ], [],
    "a FLAC folder needs a FLAC file";
  is [ mp3_for("t/f/A/B/01 X.flac") ], [], "a FLAC outside its folder";
  is [ flac_for("t/f/A/B/01 X.mp3") ], ["flac-tagged/A/B/01 X.flac"],
    "the FLAC of a converted MP3";
  is [ flac_for("t/m/A/B/01 X.mp3") ], [], "an MP3 with no FLAC";
};

done_testing;

__END__

=head1 NAME

music_sync_match.t - tests for lib/MusicSync/Match.pm

=head1 SYNOPSIS

 yath test t/music_sync_match.t

=head1 DESCRIPTION

Checks root detection and the mapping between FLAC and MP3 paths.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
