package MusicSync::Ratings;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter qw( import );

use MusicSync::Match qw( local_song          roots     roots_line );
use MusicSync::Plex  qw( plex_library_tracks plex_rate plex_section );
use MusicSync::Strawberry qw( collection_songs strawberry_running
  update_ratings );

our @EXPORT_OK
  = qw( plex_scale pull_ratings push_ratings report_ratings winner );

sub plex_scale ($rating) {
  defined $rating && $rating > 0 ? int($rating * 10 + 0.5) : undef
}

sub winner ($source, $target, $overwrite) {
  return undef unless defined $source;
  return undef if defined $target && $target == $source;
  $overwrite || !defined $target || $source > $target ? $source : undef
}

sub pairs ($plex, $dbh, $opts) {
  my $songs = collection_songs($dbh);
  my $tracks
    = plex_library_tracks($plex, plex_section($plex, $opts->{section}));
  my $roots = roots($opts, $tracks, $songs);
  my @pairs;
  my $unmatched = 0;

  for my $track (@$tracks) {
    my $song = local_song($songs, $roots, $track->{path});
    $song ? push @pairs, [ $track, $song ] : $unmatched++;
  }
  { roots => $roots, pairs => \@pairs, unmatched => $unmatched }
}

sub summary ($matched, %counts) { {
  roots         => $matched->{roots},
  to_strawberry => 0,
  to_plex       => 0,
  unmatched     => $matched->{unmatched},
  %counts,
} }

sub pull_ratings ($plex, $dbh, $opts) {
  die "Quit Strawberry before pulling ratings\n"
    if !$opts->{dry_run} && strawberry_running();
  my $matched = pairs($plex, $dbh, $opts);
  my %ratings;
  my $unchanged = 0;
  for my $pair ($matched->{pairs}->@*) {
    my ($track, $song) = @$pair;
    my $new = winner($track->{rating}, plex_scale($song->{rating}),
      $opts->{overwrite});
    defined $new ? ($ratings{ $song->{id} } = $new / 10) : $unchanged++;
  }
  update_ratings($dbh, \%ratings) unless $opts->{dry_run};
  summary(
    $matched,
    to_strawberry => scalar keys %ratings,
    unchanged     => $unchanged
  )
}

sub push_ratings ($plex, $dbh, $opts) {
  my $matched = pairs($plex, $dbh, $opts);
  my ($to_plex, $unchanged) = (0, 0);
  for my $pair ($matched->{pairs}->@*) {
    my ($track, $song) = @$pair;
    my $new = winner(plex_scale($song->{rating}), $track->{rating},
      $opts->{overwrite});
    if (defined $new) {
      plex_rate($plex, $track->{key}, $new) unless $opts->{dry_run};
      $to_plex++;
    } else {
      $unchanged++;
    }
  }
  summary($matched, to_plex => $to_plex, unchanged => $unchanged)
}

sub report_ratings ($summary, $opts) {
  print roots_line($summary->{roots});
  print "Ratings: $summary->{to_strawberry} to Strawberry, "
    . "$summary->{to_plex} to Plex, $summary->{unchanged} unchanged, "
    . "$summary->{unmatched} unmatched\n";
  print "Dry run, nothing changed\n" if $opts->{dry_run};
}

1;

__END__

=head1 NAME

MusicSync::Ratings - move track ratings between Plex and Strawberry

=head1 SYNOPSIS

 use MusicSync::Ratings qw( pull_ratings report_ratings );

 report_ratings(pull_ratings($plex, $dbh, $opts), $opts);

=head1 DESCRIPTION

Matches the tracks of one Plex music section to the songs of the Strawberry
collection by path, compares their ratings on the Plex scale of 0 to 10, and
raises the lower side to match, or takes every rating from one side with
C<overwrite>. An unrated track never clears a rating on the other side.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
