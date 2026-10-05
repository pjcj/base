#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use FindBin ();
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Path::Tiny ();
use Test2::V0  qw( dies done_testing is like lives mock ok subtest );

use MusicSync::Ratings qw( merge_ratings pull_ratings push_ratings
  report_ratings winner );
use MusicSync::Test qw(
  add_song add_songs albums_xml capture
  make_db  plex      rate_song  sections_xml
);

no warnings "experimental::signatures";

my $Tracks_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Track ratingKey="101" title="Song A" grandparentTitle="Artist"
    userRating="8.0">
    <Media id="1"><Part id="1" file="/srv/music/Artist/Album/01 Song A.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="102" title="Song B" grandparentTitle="Artist"
    userRating="6.0">
    <Media id="2"><Part id="2" file="/srv/music/Artist/Album/02 Song B.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="103" title="Thé" grandparentTitle="Other" userRating="4.0">
    <Media id="3"><Part id="3" file="/srv/music/Other/Album/01 Thé.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="105" title="Nope" grandparentTitle="Other"
    userRating="10.0">
    <Media id="5"><Part id="5" file="/srv/music/Other/Album/02 Nope.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

my $Rate
  = "PUT /:/rate?key=%d&identifier=com.plexapp.plugins.library&rating=%d";

sub rate_call ($key, $rating) { sprintf $Rate, $key, $rating }

my @Dirs;

sub rating_db () {
  my $dir = Path::Tiny->tempdir;
  push @Dirs, $dir;
  my ($dbh) = make_db($dir);
  my ($a, $b, $t) = add_songs($dbh, "$dir/mp3s");
  rate_song($dbh, $a, 0.4000000059604645);
  rate_song($dbh, $t, 1);
  $dbh
}

sub ratings ($dbh) {
  $dbh->selectall_arrayref("SELECT ROUND(rating, 2) FROM songs ORDER BY ROWID")
}

sub plex_with_tracks ($tracks = $Tracks_xml) {
  plex({
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => $tracks,
    "GET /library/sections/1/all?type=9"  => albums_xml(),
    rate_call(101, 4)                     => "",
    rate_call(103, 10)                    => "",
  })
}

sub rate_calls ($plex) { [ grep /rate/, $plex->{http}{calls}->@* ] }

subtest "winner" => sub {
  is winner(undef, 6,     0), undef, "an unrated source changes nothing";
  is winner(undef, 6,     1), undef, "even with overwrite";
  is winner(8,     8,     0), undef, "equal ratings change nothing";
  is winner(8,     8,     1), undef, "even with overwrite";
  is winner(8,     6,     0), 8,     "a higher source wins";
  is winner(6,     8,     0), undef, "a lower source loses";
  is winner(6,     8,     1), 6,     "unless overwrite";
  is winner(8,     undef, 0), 8,     "an unrated target takes the source";
};

my $Roots = { plex => "/srv/music/", local => "" };

subtest "pull" => sub {
  my $dbh  = rating_db();
  my $plex = plex_with_tracks();
  my $mock = mock "MusicSync::Ratings" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is pull_ratings($plex, $dbh, {}), {
      roots         => $Roots,
      to_strawberry => 2,
      to_plex       => 0,
      unchanged     => 1,
      duplicates    => 0,
      unmatched     => 1,
    },
    "higher Plex ratings come in";
  is ratings($dbh), [ [0.8], [0.6], [1] ],
    "writes the ratings on the Strawberry scale";
  is [ pull_ratings($plex, $dbh, { overwrite => 1 })
      ->@{ qw( to_strawberry unchanged ) } ], [ 1, 2 ],
    "overwrite takes a lower Plex rating too";
  is ratings($dbh), [ [0.8], [0.6], [0.4] ], "lowers the rating";
  is [ pull_ratings($plex, $dbh, {})->@{ qw( to_strawberry unchanged ) } ],
    [ 0, 3 ], "nothing to do on a second run";

  my $dry = rating_db();
  is pull_ratings($plex, $dry, { dry_run => 1 })->{to_strawberry}, 2,
    "dry run counts the changes";
  is ratings($dry), [ [0.4], [-1], [1] ], "dry run writes nothing";
  $mock->override(strawberry_running => sub () { 1 });
  like dies { pull_ratings($plex, $dbh, {}) }, qr/Quit Strawberry/,
    "does not write while Strawberry runs";
  ok lives { pull_ratings($plex, $dbh, { dry_run => 1 }) },
    "a dry run while Strawberry runs";
};

subtest "push" => sub {
  my $dbh  = rating_db();
  my $plex = plex_with_tracks();
  is push_ratings($plex, $dbh, {}), {
      roots         => $Roots,
      to_strawberry => 0,
      to_plex       => 1,
      unchanged     => 2,
      duplicates    => 0,
      unmatched     => 1,
    },
    "higher Strawberry ratings go out";
  is rate_calls($plex), [ rate_call(103, 10) ],
    "rates the track on the Plex scale";
  $plex = plex_with_tracks();
  is [ push_ratings($plex, $dbh, { overwrite => 1 })
      ->@{ qw( to_plex unchanged ) } ], [ 2, 1 ],
    "overwrite sends a lower rating too";
  is rate_calls($plex), [ rate_call(101, 4), rate_call(103, 10) ],
    "rates both tracks";
  $plex = plex_with_tracks();
  is push_ratings($plex, $dbh, { dry_run => 1 })->{to_plex}, 1,
    "dry run counts the changes";
  is rate_calls($plex), [], "dry run rates nothing";
};

subtest "merge" => sub {
  my $dbh  = rating_db();
  my $plex = plex_with_tracks();
  my $mock = mock "MusicSync::Ratings" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is merge_ratings($plex, $dbh, {}), {
      roots         => $Roots,
      to_strawberry => 2,
      to_plex       => 1,
      unchanged     => 0,
      duplicates    => 0,
      unmatched     => 1,
    },
    "the higher rating wins on each side";
  is ratings($dbh), [ [0.8], [0.6], [1] ],
    "Strawberry takes the higher Plex ratings";
  is rate_calls($plex), [ rate_call(103, 10) ],
    "Plex takes the higher Strawberry rating";
  my $after
    = plex_with_tracks($Tracks_xml =~ s/userRating="4\.0"/userRating="10.0"/r);
  is [ merge_ratings($after, $dbh, {})
      ->@{ qw( to_strawberry to_plex unchanged ) } ], [ 0, 0, 3 ],
    "nothing to do on a second run";
  my $dry = rating_db();
  $plex = plex_with_tracks();
  is [ merge_ratings($plex, $dry, { dry_run => 1 })
      ->@{ qw( to_strawberry to_plex ) } ], [ 2, 1 ],
    "dry run counts the changes";
  is ratings($dry),     [ [0.4], [-1], [1] ], "dry run writes nothing";
  is rate_calls($plex), [],                   "dry run rates nothing";
  $mock->override(strawberry_running => sub () { 1 });
  like dies { merge_ratings($plex, $dbh, {}) }, qr/Quit Strawberry/,
    "does not write while Strawberry runs";
};

my $Dupes_xml = <<~XML;
  <?xml version="1.0" encoding="UTF-8"?>
  <MediaContainer size="4">
  <Track ratingKey="201" guid="plex://track/d1" parentRatingKey="201"
    title="Song" grandparentTitle="Artist" duration="200000" userRating="8.0">
    <Media id="1" bitrate="320">
    <Part id="1" file="/srv/music/t/f/Artist/Album/01 Song.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="202" guid="plex://track/d1" parentRatingKey="202"
    title="Song" grandparentTitle="Artist" duration="201000" userRating="8.0">
    <Media id="2" bitrate="192">
    <Part id="2" file="/srv/music/t/m/Artist/Best Of/05 Song.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="203" guid="plex://track/d2" parentRatingKey="201"
    title="Other" grandparentTitle="Artist" duration="100000" userRating="6.0">
    <Media id="3" bitrate="320">
    <Part id="3" file="/srv/music/t/m/Artist/Album/02 Other.mp3"/>
    </Media>
  </Track>
  <Track ratingKey="204" guid="plex://track/d2" parentRatingKey="202"
    title="Something Else" grandparentTitle="Artist" duration="100000"
    userRating="6.0">
    <Media id="4" bitrate="320">
    <Part id="4" file="/srv/music/t/m/Artist/Best Of/09 Something Else.mp3"/>
    </Media>
  </Track>
  </MediaContainer>
  XML

sub dupes_db () {
  my $dir = Path::Tiny->tempdir;
  push @Dirs, $dir;
  my ($dbh) = make_db($dir);
  my @ids = map add_song($dbh, "$dir/mp3s", $_, "Song", "Artist"),
    "t/f/Artist/Album/01 Song.mp3",  "t/m/Artist/Best Of/05 Song.mp3",
    "t/m/Artist/Album/02 Other.mp3", "t/m/Artist/Best Of/09 Something Else.mp3";
  rate_song($dbh, $ids[1], 1);
  $dbh
}

subtest "duplicates" => sub {
  my $dbh  = dupes_db();
  my $plex = plex_with_tracks($Dupes_xml);
  my $mock = mock "MusicSync::Ratings" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  is pull_ratings($plex, $dbh, {}), {
      roots         => $Roots,
      to_strawberry => 3,
      to_plex       => 0,
      unchanged     => 0,
      duplicates    => 1,
      unmatched     => 0,
    },
    "the winner takes the shared rating and the loser is left alone";
  is ratings($dbh), [ [0.8], [1], [0.6], [0.6] ],
    "a doubt group takes the rating on every copy";
  is [
    push_ratings($plex, $dbh, {})->@{ qw( to_plex unchanged duplicates ) } ],
    [ 0, 3, 1 ], "push never sends from a loser";
  is rate_calls($plex), [], "so the five stars on the loser stay local";
  my $fresh = dupes_db();
  is [ merge_ratings($plex, $fresh, {})
      ->@{ qw( to_strawberry to_plex duplicates ) } ], [ 3, 0, 1 ],
    "merge does neither for a loser";
  is rate_calls($plex), [], "and rates nothing";
};

subtest "report" => sub {
  my $summary = {
    roots         => { plex => "/m/", local => "t/" },
    to_strawberry => 2,
    to_plex       => 0,
    unchanged     => 5,
    duplicates    => 3,
    unmatched     => 1,
  };
  my $lines
    = "Plex root /m/ maps to collection folder t/\n"
    . "Ratings: 2 to Strawberry, 0 to Plex, 5 unchanged, 1 unmatched\n"
    . "Losing copies left alone: 3\n";
  is capture(sub { report_ratings($summary, {}) }), $lines,
    "roots and counts";
  is capture(sub { report_ratings($summary, { dry_run => 1 }) }),
    "${lines}Dry run, nothing changed\n", "dry run says so";
};

done_testing;

__END__

=head1 NAME

music_sync_ratings.t - tests for lib/MusicSync/Ratings.pm

=head1 SYNOPSIS

 yath test t/music_sync_ratings.t

=head1 DESCRIPTION

Moves ratings between a fake Plex server and a temporary Strawberry database
in both directions, with and without overwriting.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
