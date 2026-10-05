package MusicSync::Ratings;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter qw( import );

use MusicSync::Duplicates qw( loser_keys section_groups );
use MusicSync::Match      qw( roots_line );
use MusicSync::Plex       qw( plex_rate );
use MusicSync::Strawberry qw( plex_scale strawberry_running update_ratings );

our @EXPORT_OK
  = qw( merge_ratings pull_ratings push_ratings report_ratings winner );

sub winner ($source, $target, $overwrite) {
  return undef unless defined $source;
  return undef if defined $target && $target == $source;
  $overwrite || !defined $target || $source > $target ? $source : undef
}

sub sync ($plex, $dbh, $opts, %way) {
  die "Quit Strawberry before writing ratings\n"
    if $way{in} && !$opts->{dry_run} && strawberry_running();
  my $found = section_groups($plex, $dbh, $opts);
  my $loser = loser_keys($found->{groups});
  my %ratings;
  my ($to_plex, $unchanged, $duplicates, $unmatched) = (0, 0, 0, 0);
  for my $track ($found->{tracks}->@*) {
    my $song = $track->{song};
    $unmatched++,  next unless $song;
    $duplicates++, next if $loser->{ $track->{key} };
    my $local = plex_scale($song->{rating});
    my $to_local
      = $way{in} ? winner($track->{rating}, $local, $opts->{overwrite}) : undef;
    my $to_remote
      = $way{out}
      ? winner($local, $track->{rating}, $opts->{overwrite})
      : undef;
    if (defined $to_local) {
      $ratings{ $song->{id} } = $to_local / 10;
    } elsif (defined $to_remote) {
      plex_rate($plex, $track->{key}, $to_remote) unless $opts->{dry_run};
      $to_plex++;
    } else {
      $unchanged++;
    }
  }
  update_ratings($dbh, \%ratings) if %ratings && !$opts->{dry_run};
  {
    roots         => $found->{roots},
    to_strawberry => scalar keys %ratings,
    to_plex       => $to_plex,
    unchanged     => $unchanged,
    duplicates    => $duplicates,
    unmatched     => $unmatched,
  }
}

sub pull_ratings ($plex, $dbh, $opts) { sync($plex, $dbh, $opts, in  => 1) }
sub push_ratings ($plex, $dbh, $opts) { sync($plex, $dbh, $opts, out => 1) }

sub merge_ratings ($plex, $dbh, $opts) {
  sync($plex, $dbh, $opts, in => 1, out => 1)
}

sub report_ratings ($summary, $opts) {
  print roots_line($summary->{roots});
  print "Ratings: $summary->{to_strawberry} to Strawberry, "
    . "$summary->{to_plex} to Plex, $summary->{unchanged} unchanged, "
    . "$summary->{unmatched} unmatched\n";
  print "Losing copies left alone: $summary->{duplicates}\n";
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
The losing copies of a duplicate group, as L<MusicSync::Duplicates> finds
them, are left alone in both directions.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
