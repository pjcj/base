#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use FindBin ();
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Path::Tiny ();
use Test2::V0  qw( dies done_testing is like mock ok subtest );

use MusicSync::Duplicates qw(
  album_kind   bitrate_band    duplicate_groups list_duplicates
  loser_keys   mark_duplicates rank_key         report_marks
  titles_match track_pairs     various
);
use MusicSync::Test qw(
  add_song albums_xml capture   dupes_xml
  make_db  plex       rate_song sections_xml
  tracks_xml
);

no warnings "experimental::signatures";

my $Albums = {
  1 => { title => "Album", artist => "Artist", year => 1990, kinds => [] },
  2 => {
    title  => "Best Of",
    artist => "Artist",
    year   => 1999,
    kinds  => [ "Album", "Compilation" ],
  },
  3 => {
    title  => "Hits",
    artist => "Various Artists",
    year   => 2001,
    kinds  => [ "Album", "Compilation", "DJ Mix" ],
  },
  4 => { title => "Undated", artist => "Artist", year => undef, kinds => [] },
  5 => {
    title  => "Live",
    artist => "Artist",
    year   => 1995,
    kinds  => [ "Album", "Live" ],
  },
  6 => { title => "Early", artist => "Artist", year => 1985, kinds => [] },
};

my $n = 0;

sub track (%field) {
  $n++;
  {
    key       => 100 + $n,
    guid      => "plex://track/g1",
    rel       => "t/m/Artist/Album/0$n Song.mp3",
    title     => "Song",
    artist    => "Artist",
    duration  => 200_000,
    bitrate   => 320,
    size      => 8_000_000,
    album_key => 1,
    %field,
  }
}

sub winner (@tracks) {
  duplicate_groups(\@tracks, $Albums)->[0]{winner}{rel}
}

subtest "bitrate bands" => sub {
  is bitrate_band(320),   0, "top band from 240";
  is bitrate_band(240),   0, "at the edge";
  is bitrate_band(239),   1, "just under";
  is bitrate_band(176),   1, "second band from 176";
  is bitrate_band(175),   2, "third band";
  is bitrate_band(112),   2, "third band from 112";
  is bitrate_band(111),   3, "bottom band";
  is bitrate_band(undef), 3, "unknown bitrate is the bottom band";
};

subtest "various artists" => sub {
  my $own = track();
  ok !various($own, $Albums->{1}), "an artist's own album";
  ok various($own,  $Albums->{3}), "by album artist";
  my $folder = track(rel => "t/f/Various Artists/Hits/01 Song.mp3");
  ok various($folder, $Albums->{1}), "by folder when Plex renamed the artist";
  ok !various(track(rel => "x.mp3"), $Albums->{1}), "a short path is not";
};

subtest "album kinds" => sub {
  my $track = track();
  is album_kind($track, $Albums->{1}), 0, "original";
  is album_kind($track, $Albums->{2}), 1, "the artist's own compilation";
  is album_kind($track, $Albums->{3}), 2, "Various Artists";
  is album_kind($track, $Albums->{5}), 0, "a live album is an original";
  is album_kind($track, { kinds => ["Soundtrack"] }),        1, "a soundtrack";
  is album_kind($track, { kinds => [ "Album", "DJ Mix" ] }), 1, "a DJ mix";
  is album_kind($track, { kinds => ["Remix"] }),             0, "a remix album";
  is album_kind($track, {}), 0, "an album Plex did not list";
  is album_kind(track(rel => "t/m/Various Artists/X/01 Song.mp3"), {}), 2,
    "Various Artists by folder with no album";
};

subtest "rank key" => sub {
  is rank_key(
    track(rel => "t/f/Artist/Album/01 Song.mp3", bitrate => 128),
    $Albums->{2}
    ),
    [ 0, 0, 1, 1999, -128, -8_000_000, "t/f/Artist/Album/01 Song.mp3" ],
    "a FLAC rip ignores its bitrate band";
  is rank_key(
    track(rel => "t/m/Artist/Album/01 Song.mp3", bitrate => 128),
    $Albums->{4}
    ),
    [ 1, 2, 0, 9999, -128, -8_000_000, "t/m/Artist/Album/01 Song.mp3" ],
    "an MP3 with no year sorts last";
  is rank_key(
    track(rel => "t/m/A/B/01 Song.mp3", bitrate => undef, size => undef), {}
    ),
    [ 1, 3, 0, 9999, 0, 0, "t/m/A/B/01 Song.mp3" ],
    "missing numbers count as zero";
};

subtest "titles match" => sub {
  ok titles_match("Song",        "Song"),           "equal";
  ok titles_match("Song",        "song"),           "case does not matter";
  ok titles_match("Realize",     "Realize (Live)"), "brackets are dropped";
  ok titles_match("TVC 15",      "TVC15"),          "spacing does not matter";
  ok titles_match("Hyperballad", "Hyper‐Ballad"),   "nor a hyphen";
  ok titles_match("Another Song Title", "Song Title (Edit)"),
    "half the words of the shorter title";
  ok !titles_match("Joan of Arc (Maid of Orleans)", "Maid of Orleans"),
    "bracketed words do not count";
  ok !titles_match(
    "Rockin' Around the Christmas Tree",
    "Mel and Kim - Rockin Around th"
    ),
    "a truncated title";
  ok !titles_match("You Spin Me Round", "Dolce Vita"), "different songs";
  ok !titles_match("La Ronde triste", "La Veuve noire"),
    "one word of three is not enough";
  ok !titles_match("Realize", "Realise"), "one word differing by a letter";
  ok titles_match("(Tag)",    "Tag"),     "a title that is all brackets";
  ok !titles_match("(Tag)",   "(Other)"), "two such titles that differ";
};

subtest "ranking order" => sub {
  my ($one, $two) = ("t/m/A/B/01 Song.mp3", "t/m/A/C/01 Song.mp3");
  is winner(
    track(rel => "t/f/A/B/01 Song.mp3", bitrate => 128),
    track(rel => $two)
    ),
    "t/f/A/B/01 Song.mp3", "a FLAC rip beats an MP3 whatever the bitrate";
  is winner(
    track(rel => $one, bitrate => 175),
    track(rel => $two, bitrate => 176, album_key => 3)
    ),
    $two, "a higher band beats a better album";
  is winner(
    track(rel => $one, bitrate => 180, album_key => 2),
    track(rel => $two, bitrate => 200, album_key => 3)
    ),
    $one, "within a band the album kind decides";
  is winner(
    track(rel => $one, album_key => 2),
    track(rel => $two, album_key => 1)
    ),
    $two, "an original beats a compilation";
  is winner(
    track(rel => $one, album_key => 3),
    track(rel => $two, album_key => 2)
    ),
    $two, "the artist's compilation beats Various Artists";
  is winner(
    track(rel => $one, album_key => 1),
    track(rel => $two, album_key => 6)
    ),
    $two, "the earlier album wins";
  is winner(
    track(rel => $one, album_key => 4),
    track(rel => $two, album_key => 1)
    ),
    $two, "a missing year loses";
  is winner(
    track(rel => $one, bitrate => 256),
    track(rel => $two, bitrate => 320)
    ),
    $two, "the higher bitrate wins in a band";
  is winner(track(rel => $one, size => 1), track(rel => $two, size => 2)),
    $two, "the larger file wins";
  is winner(
    track(rel => "t/m/A/B_C/01 Song.mp3"),
    track(rel => "t/m/A/B & C/01 Song.mp3")
    ),
    "t/m/A/B & C/01 Song.mp3", "the path decides last";
};

subtest "groups" => sub {
  my @tracks = (
    track(key => 1, guid => "plex://track/g2", rel => "t/m/A/B/01 Song.mp3"),
    track(key => 2, guid => "plex://track/g2", rel => "t/m/A/B_/01 Song.mp3"),
    track(key => 3, guid => "plex://track/g1", rel => "t/m/A/X/01 Song.mp3"),
    track(
      key      => 4,
      guid     => "plex://track/g1",
      rel      => "t/f/A/X/01 Song.mp3",
      duration => 205_000
    ),
    track(
      key      => 5,
      guid     => "plex://track/g1",
      rel      => "t/m/A/Y/01 Song.mp3",
      duration => 201_000
    ),
    track(key => 6,  guid => "plex://track/g3"),
    track(key => 7,  guid => "local://1234"),
    track(key => 8,  guid => "local://1234"),
    track(key => 9,  guid => undef),
    track(key => 10, guid => "plex://track/g4", rel => undef),
    track(key => 11, guid => "plex://track/g4", rel => undef),
  );
  my $groups = duplicate_groups(\@tracks, $Albums);
  is [ map $_->{guid}, @$groups ], [ "plex://track/g1", "plex://track/g2" ],
    "groups of shared Plex guids in order of the winner's path";
  my ($g1, $g2) = @$groups;
  is $g1->{winner}{rel}, "t/f/A/X/01 Song.mp3", "the winner";
  is [ map $_->{rel}, $g1->{losers}->@* ],
    [ "t/m/A/X/01 Song.mp3", "t/m/A/Y/01 Song.mp3" ], "the losers in order";
  is $g1->{doubt},  undef, "within 5 seconds and the same title";
  is $g1->{folder}, 0,     "not a folder duplicate";
  is $g2->{folder}, 1,     "a folder duplicate";
  is loser_keys($groups), { 3 => $g1, 5 => $g1, 2 => $g2 },
    "losers of clean groups";
};

subtest "doubt" => sub {
  my $far
    = duplicate_groups([ track(), track(duration => 205_001) ], $Albums)->[0];
  is $far->{doubt}, "duration", "over 5 seconds apart";
  my $close
    = duplicate_groups([ track(), track(duration => 195_000) ], $Albums)->[0];
  is $close->{doubt}, undef, "5 seconds apart";
  my $title
    = duplicate_groups([ track(), track(title => "Other"), track() ], $Albums)
    ->[0];
  is $title->{doubt}, "title", "one loser with another title";
  is loser_keys([ $far, $close, $title ]),
    { $close->{losers}[0]{key} => $close }, "doubt groups have no losers";
  is duplicate_groups([ track(), track(duration => undef) ], $Albums)
    ->[0]{doubt}, "duration", "a loser with no duration";
  is duplicate_groups(
    [ track(rel => "t/f/A/B/01 Song.mp3", duration => undef), track() ],
    $Albums
  )->[0]{doubt}, "duration", "a winner with no duration";
};

subtest "unknown albums" => sub {
  my $group = duplicate_groups(
    [
      track(rel => "t/m/A/C/01 Song.mp3", album_key => undef),
      track(rel => "t/m/A/B/01 Song.mp3", album_key => 99),
    ],
    $Albums
  )->[0];
  is $group->{winner}{rel}, "t/m/A/B/01 Song.mp3",
    "both rank as originals without a year, so the path decides";
  is $group->{folder}, 1, "and that makes a folder duplicate";
};

subtest "pairs" => sub {
  my ($one, $two) = ("t/m/A/B/01 Song.mp3", "t/m/A/C/01 Song.mp3");
  my $x     = "plex://track/x";
  my $y     = "plex://track/y";
  my $bands = sub (@tracks) {
    [ map "$_->{band} $_->{gap}", track_pairs(\@tracks, $Albums)->@* ]
  };
  is $bands->(
    track(rel => $one, guid => $x),
    track(rel => $two, guid => $y, duration => 203_000)
    ),
    ["same album 3000"], "three seconds apart on one album";
  is $bands->(
    track(rel => $one, guid => $x),
    track(rel => $two, guid => $y, duration => 203_001)
    ),
    [], "further apart is no pair";
  is $bands->(track(rel => $one, guid => $x), track(rel => $two, guid => $x)),
    [], "the same guid is a group, not a pair";
  is $bands->(
    track(rel => $one, guid => $x, album_key => undef),
    track(rel => $two, guid => $y)
    ),
    ["catalogue 0"], "no album on one side";
  is $bands->(
    track(rel => $one, guid => $x, album_key => 2),
    track(rel => $two, guid => $y)
    ),
    ["catalogue 0"], "different albums";
  is $bands->(
    track(rel => $one, guid => $x, album_key => 2),
    track(rel => $two, guid => "local://1")
    ),
    ["local guid 0"], "a local guid on one side of two albums";
  is $bands->(
    track(rel => $one, guid => undef, album_key => 2),
    track(rel => $two, guid => $y)
    ),
    ["local guid 0"], "no guid counts as local";
  is $bands->(
    track(rel => $one, guid => undef),
    track(rel => $two, guid => undef)
    ),
    [], "two tracks without guids";
  is $bands->(track(rel => undef, guid => $x),
    track(rel => $two, guid => $y)), [],
    "a track outside the root is left out";
  is $bands->(
    track(rel => $one, guid => $x, duration => undef),
    track(rel => $two, guid => $y)
    ),
    [], "so is one with no duration";
  is $bands->(
    track(rel => "t/m/Various Artists/X/01 Song.mp3", guid => $x),
    track(rel => "t/m/Various Artists/Y/01 Song.mp3", guid => $y)
    ),
    [], "Various Artists tracks need their own artist";
  is $bands->(
    track(
      rel          => "t/m/Various Artists/X/01 Song.mp3",
      guid         => $x,
      track_artist => "Someone"
    ),
    track(
      rel          => "t/m/Various Artists/Y/01 Song.mp3",
      guid         => $y,
      track_artist => "someone"
    )
    ),
    ["same album 0"], "and match on it whatever the case";
  is $bands->(
    track(rel => $one, guid => $x, title => "Song"),
    track(rel => $two, guid => $y, title => "Other")
    ),
    [], "different titles";
};

subtest "list" => sub {
  my $dir = Path::Tiny->tempdir;
  my ($dbh) = make_db($dir);
  add_song($dbh, "$dir/mp3s", @$_, "Artist")
    for (
      [ "t/f/Artist/Album/01 Song A.mp3",        "Song A" ],
      [ "t/m/Artist/Best Of/05 Song A.mp3",      "Song A" ],
      [ "t/m/Artist/Album/02 Song B.mp3",        "Song B" ],
      [ "t/m/Various Artists/Hits/07 Other.mp3", "Other" ],
      [ "t/m/Artist/Album/03 Song C.mp3",        "Song C" ],
      [ "t/m/Artist/Album/04 Song D.mp3",        "Song D" ]
    );
  my $plex = plex({
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => dupes_xml(),
    "GET /library/sections/1/all?type=9"  => albums_xml(),
  });
  is capture(sub { list_duplicates($plex, $dbh, {}) }), <<~TEXT,
    Plex root /srv/music/ maps to the collection root
    Artist - Song A
      W  320 kbps   3:00  t/f/Artist/Album/01 Song A.mp3
      L  192 kbps   3:01  t/m/Artist/Best Of/05 Song A.mp3
    Artist - Song B, doubt title
      W  320 kbps   3:20  t/m/Artist/Album/02 Song B.mp3
      L  320 kbps   3:20  t/m/Various Artists/Hits/07 Other.mp3
    Artist - Song C, folder duplicate
      W  256 kbps   4:00  t/m/Artist/Album/03 Song C.mp3
      L  256 kbps   4:00  t/m/Artist/Album_/03 Song C.mp3 (no local song)
    Artist - Song D, doubt duration
      W  320 kbps   2:30  t/m/Artist/Album/04 Song D.mp3
      L    ? kbps   0:00  t/m/Artist/Best Of/09 Song D.mp3 (no local song)
    Groups: 4, 2 clean, 2 in doubt, 1 folder duplicate
    Losers: 2, 1 with no local song
    Pairs with different guids
      Artist - Song A, same album, 2.0 s apart
        t/f/Artist/Album/01 Song A.mp3
        t/m/Artist/Album/01 Song A.mp3
      Artist - Song B, local guid, 1.0 s apart
        t/m/Artist/Album/02 Song B.mp3
        t/m/Various Artists/Hits/02 Song B.mp3
      Artist - Song A, catalogue, 1.0 s apart
        t/m/Artist/Album/01 Song A.mp3
        t/m/Artist/Best Of/05 Song A.mp3
      Artist - Song D, catalogue, 1.0 s apart
        t/m/Artist/Album/04 Song D.mp3
        t/m/Artist/Singles/01 Song D.mp3
    Pairs: 4, 1 same album, 1 local guid, 2 catalogue
    TEXT
    "every group with its winner, losers and notes, then the pairs";
  is $plex->{http}{calls}, [
      "GET /library/sections",
      "GET /library/sections/1/all?type=10",
      "GET /library/sections/1/all?type=9",
    ],
    "one listing of tracks and one of albums";
  my $alone = plex({
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => tracks_xml(),
    "GET /library/sections/1/all?type=9"  => albums_xml(),
  });
  is capture(sub { list_duplicates($alone, $dbh, {}) }), <<~TEXT,
    Plex root /srv/music/ maps to collection folder t/f/
    Groups: 0, 0 clean, 0 in doubt, 0 folder duplicates
    Losers: 0, 0 with no local song
    Pairs: 0, 0 same album, 0 local guid, 0 catalogue
    TEXT
    "a section with no shared guids and no pairs";
};

subtest "mark" => sub {
  my $dir   = Path::Tiny->tempdir;
  my ($dbh) = make_db($dir);
  my %id    = map { $_->[0] => add_song($dbh, "$dir/mp3s", @$_, "Artist") } (
    [ "t/f/Artist/Album/01 Song A.mp3",        "Song A" ],
    [ "t/m/Artist/Best Of/05 Song A.mp3",      "Song A" ],
    [ "t/m/Artist/Album/02 Song B.mp3",        "Song B" ],
    [ "t/m/Various Artists/Hits/07 Other.mp3", "Other" ],
    [ "t/m/Artist/Album/03 Song C.mp3",        "Song C" ],
    [ "t/m/Artist/Album_/03 Song C.mp3",       "Song C" ],
    [ "t/m/Artist/Album/04 Song D.mp3",        "Song D" ],
  );
  rate_song($dbh, $id{"t/m/Artist/Best Of/05 Song A.mp3"},      0.8);
  rate_song($dbh, $id{"t/m/Various Artists/Hits/07 Other.mp3"}, 0.8);
  my $rating = sub ($rel) {
    $dbh->selectrow_array(
      "SELECT rating FROM songs WHERE ROWID = ?",
      undef, $id{$rel}
    )
  };
  my $responses = {
    "GET /library/sections"               => sections_xml(),
    "GET /library/sections/1/all?type=10" => dupes_xml(),
    "GET /library/sections/1/all?type=9"  => albums_xml(),
  };
  my $roots   = { plex => "/srv/music/", local => "" };
  my $running = mock "MusicSync::Duplicates" =>
    (override => [ strawberry_running => sub () { 1 } ]);
  like dies { mark_duplicates(plex($responses), $dbh, {}) },
    qr/Quit Strawberry before marking duplicates/,
    "refuses to write while Strawberry runs";
  is mark_duplicates(plex($responses), $dbh, { dry_run => 1 }),
    { roots => $roots, marked => 2, already => 0, missing => 0, doubt => 2 },
    "a dry run counts what it would mark";
  is $rating->("t/m/Artist/Best Of/05 Song A.mp3"), 0.8,
    "and changes nothing";
  undef $running;
  my $quiet = mock "MusicSync::Duplicates" =>
    (override => [ strawberry_running => sub () { 0 } ]);
  my $summary = mark_duplicates(plex($responses), $dbh, {});
  is $summary,
    { roots => $roots, marked => 2, already => 0, missing => 0, doubt => 2 },
    "marks the losers of the clean groups";
  is $rating->("t/m/Artist/Best Of/05 Song A.mp3"), 0.2,
    "a rated loser goes down to one star";
  is $rating->("t/m/Artist/Album_/03 Song C.mp3"), 0.2,
    "an unrated loser gets one star";
  is $rating->("t/m/Various Artists/Hits/07 Other.mp3"), 0.8,
    "a loser in a doubt group keeps its rating";
  is $rating->("t/f/Artist/Album/01 Song A.mp3"), -1,
    "the winner stays unrated";
  is mark_duplicates(plex($responses), $dbh, {}),
    { roots => $roots, marked => 0, already => 2, missing => 0, doubt => 2 },
    "a second run has nothing to do";
  is capture(sub { report_marks($summary, {}) }), <<~TEXT, "the report";
    Plex root /srv/music/ maps to the collection root
    Losers: 2 marked, 0 already one star, 0 with no local song
    Groups in doubt left alone: 2
    TEXT
  like capture(sub { report_marks($summary, { dry_run => 1 }) }),
    qr/\nDry run, nothing changed\n$/, "a dry run says so";
};

done_testing;
