#!/usr/bin/perl -CSAD

use 5.18.2;
use warnings;
use utf8::all;

use Data::Printer deparse => 1;
use Encode;
use Getopt::Long;
use Path::Tiny;
use Unicode::Normalize qw( NFC NFD NFKC NFKD );

sub pd { say join " ", map ref() ? p $_ : $_ // "*undef*", @_ }

my $Defaults = {
    debug   => 0,
    verbose => 0,
};

our $O = {};
sub get_options {
    my $o = { argv => [@ARGV] };
    die "Bad option" unless GetOptions($o, qw(
        conf=s
        debug!
        verbose!
    ));
    $o->{args} = [@ARGV];

    our $CONF = {};
    if (my $file = $o->{conf}) {
        unless (my $ret = do $file) {
            warn "couldn't parse $file: $@" if $@;
            warn "couldn't do $file: $!"    unless defined $ret;
            warn "couldn't run $file"       unless $ret;
        }
    }
    %$O = (%$Defaults, %$CONF, %$o);
    $O->{begin}->() if $O->{begin};
    pd "Options: ", $O if $O->{verbose};
}

sub main {
    get_options;

    # implementation

    0
}

main

__END__

=head1 NAME

%FILE% - ...

=head1 SYNOPSIS

 %FILE%

=head1 DESCRIPTION

...

=head1 OPTIONS

The following command line options are supported:

 -h -help              - show help
 -i -info              - show documentation
 -v -version           - show version

=head1 DETAILS

=head1 EXIT STATUS

The following exit values are returned:

0   All operations were completed successfully.

>0  An error occurred.

=head1 SEE ALSO

=head1 BUGS

=head1 LICENCE

Copyright %YEAR%, Paul Johnson (paul@pjcj.net)

=cut
