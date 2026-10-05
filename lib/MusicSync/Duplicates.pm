package MusicSync::Duplicates;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter qw( import );

use MusicSync::Match qw( from_flac local_song plex_rel roots roots_line );
use MusicSync::Plex  qw( plex_library_albums plex_library_tracks plex_section );
use MusicSync::Strawberry qw( collection_songs );

our @EXPORT_OK = qw(
  album_kind bitrate_band duplicate_groups list_duplicates
  loser_keys rank_key     titles_match     various
);

sub bitrate_band ($bitrate) {
  my $kbps = $bitrate // 0;
  $kbps >= 240 ? 0 : $kbps >= 176 ? 1 : $kbps >= 112 ? 2 : 3
}

sub various ($track, $album) {
  my $folder = (split m|/|, $track->{rel})[-3] // "";
  $folder eq "Various Artists" || ($album->{artist} // "") eq "Various Artists"
}

my %Compilation = map { $_ => 1 } "Compilation", "Soundtrack", "DJ Mix";

sub album_kind ($track, $album) {
  return 2 if various($track, $album);
  (grep $Compilation{$_}, ($album->{kinds} // [])->@*) ? 1 : 0
}

sub rank_key ($track, $album) {
  my $flac = from_flac($track->{rel});
  [
    $flac ? 0 : 1,
    $flac ? 0 : bitrate_band($track->{bitrate}),
    album_kind($track, $album),
    $album->{year} // 9999,
    -($track->{bitrate} // 0),
    -($track->{size}    // 0),
    $track->{rel},
  ]
}

sub by_rank ($x, $y) {
  for my $i (0 .. 5) {
    my $order = $x->[$i] <=> $y->[$i];
    return $order if $order;
  }
  $x->[6] cmp $y->[6]
}

sub same_but_path ($x, $y) { !grep { $x->[$_] != $y->[$_] } 0 .. 5 }

sub squash ($title) { lc($title) =~ s/[^\p{L}\p{N}]//gr }

sub title_words ($title) {
  my $words = lc $title;
  $words =~ s/\s*[(\[].*?[)\]]//g;
  $words =~ s/[^\p{L}\p{N}\s]+/ /g;
  [ split " ", $words ]
}

sub titles_match ($x, $y) {
  return 1 if squash($x) eq squash($y);
  my ($short, $long) = sort { @$a <=> @$b } title_words($x), title_words($y);
  return 0 unless @$short;
  my %in = map { $_ => 1 } @$long;
  2 * grep($in{$_}, @$short) >= @$short
}

sub doubt ($winner, $losers) {
  for my $loser (@$losers) {
    return "duration"
      if abs(($loser->{duration} // 0) - ($winner->{duration} // 0)) > 5000;
    return "title" unless titles_match($winner->{title}, $loser->{title});
  }
  undef
}

sub group ($guid, $tracks, $albums) {
  my %rank = map {
    $_->{key} => rank_key($_, $albums->{ $_->{album_key} // "" } // {})
  } @$tracks;
  my ($winner, @losers)
    = sort { by_rank($rank{ $a->{key} }, $rank{ $b->{key} }) } @$tracks;
  {
    guid   => $guid,
    winner => $winner,
    losers => \@losers,
    doubt  => doubt($winner, \@losers),
    folder => same_but_path($rank{ $winner->{key} }, $rank{ $losers[0]{key} })
    ? 1
    : 0,
  }
}

sub duplicate_groups ($tracks, $albums) {
  my %by_guid;
  for my $track (@$tracks) {
    next unless defined $track->{rel} && ($track->{guid} // "") =~ m|^plex://|;
    push $by_guid{ $track->{guid} }->@*, $track;
  }
  my @groups = map group($_, $by_guid{$_}, $albums), grep $by_guid{$_}->@* > 1,
    keys %by_guid;
  [ sort { $a->{winner}{rel} cmp $b->{winner}{rel} } @groups ]
}

sub loser_keys ($groups) {
  my %loser;
  for my $group (grep !$_->{doubt}, @$groups) {
    $loser{ $_->{key} } = $group for $group->{losers}->@*;
  }
  \%loser
}

sub section_groups ($plex, $dbh, $opts) {
  my $section = plex_section($plex, $opts->{section});
  my $tracks  = plex_library_tracks($plex, $section);
  my $albums  = plex_library_albums($plex, $section);
  my $songs   = collection_songs($dbh);
  my $roots   = roots($opts, $tracks, $songs);

  for my $track (@$tracks) {
    $track->{rel}  = plex_rel($roots->{plex}, $track->{path});
    $track->{song} = local_song($songs, $roots, $track->{path});
  }
  { roots => $roots, groups => duplicate_groups($tracks, $albums) }
}

sub label ($track) {
  # uncoverable condition false note:the artist is always a string
  ($track->{track_artist} // $track->{artist}) . " - $track->{title}"
}

sub group_notes ($group) {
  my @notes;
  push @notes, "doubt $group->{doubt}" if $group->{doubt};
  push @notes, "folder duplicate"      if $group->{folder};
  @notes ? ", " . join(", ", @notes) : ""
}

sub clock ($ms) {
  my $seconds = int(($ms // 0) / 1000 + 0.5);
  sprintf "%d:%02d", $seconds / 60, $seconds % 60
}

sub track_line ($mark, $track) {
  my $note = $track->{song} ? "" : " (no local song)";
  sprintf "  %s  %3s kbps  %5s  %s%s\n", $mark, $track->{bitrate} // "?",
    clock($track->{duration}), $track->{rel}, $note
}

sub list_duplicates ($plex, $dbh, $opts) {
  my $found  = section_groups($plex, $dbh, $opts);
  my $groups = $found->{groups};
  print roots_line($found->{roots});
  my ($doubt, $folder, $losers, $missing) = (0, 0, 0, 0);
  for my $group (@$groups) {
    print label($group->{winner}) . group_notes($group) . "\n";
    print track_line("W", $group->{winner});
    print track_line("L", $_) for $group->{losers}->@*;
    $folder++ if $group->{folder};
    $doubt++, next if $group->{doubt};
    $losers  += $group->{losers}->@*;
    $missing += grep !$_->{song}, $group->{losers}->@*;
  }
  my $clean = @$groups - $doubt;
  my $rips  = $folder == 1 ? "folder duplicate" : "folder duplicates";
  print "Groups: "
    . @$groups
    . ", $clean clean, $doubt in doubt, "
    . "$folder $rips\n";
  print "Losers: $losers, $missing with no local song\n";
}

1;

__END__

=head1 NAME

MusicSync::Duplicates - find the copies of one recording and pick a winner

=head1 SYNOPSIS

 use MusicSync::Duplicates qw( duplicate_groups loser_keys );

 my $groups = duplicate_groups($tracks, $albums);
 my $losers = loser_keys($groups);

=head1 DESCRIPTION

Tracks that the Plex agent matched to the same recording share one guid.
This module groups the tracks of a section by that guid, ranks each group
so that one copy wins, and checks that the losers really are the same
recording.

=head2 Ranking

The ranking key compares these in order, and the first difference decides.

=over

=item 1. Source. An MP3 converted from FLAC under C<t/f/> beats one under
C<t/m/>.

=item 2. Bitrate band of a C<t/m/> file, split at 112, 176 and 240 kbps.

=item 3. Album kind. An original, then the artist's own compilation, then
Various Artists.

=item 4. Album year, earlier first and missing last.

=item 5. Bitrate.

=item 6. File size.

=item 7. Path.

=back

Live and Remix albums count as originals. Compilation, Soundtrack and DJ Mix
albums count as compilations. An album is Various Artists when Plex names
that album artist or when the artist folder of the file is called that,
since Plex sometimes renames the placeholder artist.

A group whose first two tracks tie on everything but the path is a folder
duplicate, one album ripped twice into two folders.

=head2 Guards

A loser must be within five seconds of the winner. Its title must also
share at least half the words of the shorter title, after dropping
bracketed parts and punctuation, or be equal once everything but letters
and digits is removed. A group that fails either guard is in doubt and no
loser in it is marked.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
