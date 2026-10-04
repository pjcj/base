package MusicSync::Match;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter           qw( import );
use Unicode::Normalize qw( NFC );

our @EXPORT_OK = qw(
  detect_roots flac_for local_rel local_song
  mp3_for      plex_rel roots     roots_line
  track_key
);

sub detect_roots ($tracks, $local) {
  my %by_name;
  push $by_name{ (split m|/|)[-1] }->@*, $_ for keys %$local;
  my ($roots, $depth) = (undef, 0);
  for my $track (@$tracks) {
    my @plex = split m|/|, NFC($track->{path} // next);
    for my $key (($by_name{ $plex[-1] } // [])->@*) {
      my @local = split m|/|, $key;
      my $n     = 0;
      $n++
        while $n < @plex
        && $n < @local
        && $plex[ -1 - $n ] eq $local[ -1 - $n ];
      next if $n <= $depth;
      $depth = $n;
      $roots = {
        plex  => join("/", @plex[ 0 .. $#plex - $n ]) . "/",
        local => join("/", @local[ 0 .. $#local - $n ], ""),
      };
    }
  }
  $roots
}

sub roots ($opts, $tracks, $local) {
  my $roots = detect_roots($tracks, $local) // { plex => undef, local => "" };
  $roots->{plex}  = $opts->{plex_root}  if defined $opts->{plex_root};
  $roots->{local} = $opts->{local_root} if defined $opts->{local_root};
  $roots
}

sub roots_line ($roots) {
  return "No Plex root found, so nothing can match\n"
    unless defined $roots->{plex};
  my $local
    = $roots->{local} eq ""
    ? "the collection root"
    : "collection folder $roots->{local}";
  "Plex root $roots->{plex} maps to $local\n"
}

sub plex_rel ($root, $path) {
  return unless defined $root && defined $path && index($path, $root) == 0;
  NFC(substr $path, length $root)
}

my $Flac = { dir => "flac-tagged/", ext => ".flac" };
my $Mp3  = { dir => "t/f/",         ext => ".mp3" };

sub swap_format ($rel, $from, $to) {
  return unless index($rel, $from->{dir}) == 0 && $rel =~ /\Q$from->{ext}\E$/;
  $to->{dir}
    . substr($rel, length $from->{dir}, -length $from->{ext})
    . $to->{ext}
}

sub mp3_for  ($rel) { swap_format($rel, $Flac, $Mp3) }
sub flac_for ($rel) { swap_format($rel, $Mp3,  $Flac) }

sub local_song ($songs, $roots, $path) {
  my $rel = plex_rel($roots->{plex}, $path) // return;
  for my $try ($rel, mp3_for($rel)) {
    my $song = $songs->{ $roots->{local} . $try };
    return $song if $song;
  }
  undef
}

sub local_rel ($prefix, $rel) {
  return unless defined $rel && index($rel, $prefix) == 0;
  substr $rel, length $prefix
}

sub track_key ($key_for, $present, $opts, $rel) {
  my @keys = grep defined, map $key_for->{$_}, $rel, flac_for($rel);
  @keys = reverse @keys unless $opts->{mp3};
  return $keys[0] if $opts->{mp3} || $opts->{flac};
  my ($kept) = grep $present->{$_}, @keys;
  return $kept if defined $kept;
  $keys[0]
}

1;

__END__

=head1 NAME

MusicSync::Match - match Plex tracks to Strawberry songs by path

=head1 SYNOPSIS

 use MusicSync::Match qw( roots local_song );

 my $roots = roots($opts, $tracks, $songs);
 my $song  = local_song($songs, $roots, $track->{path});

=head1 DESCRIPTION

Finds the library root on the Plex server and the collection folder that
mirrors it, and maps a FLAC path under C<flac-tagged/> to its MP3 under
C<t/f/> and back.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
