#!/usr/bin/perl

# Copyright 2016, Paul Johnson (paul@pjcj.net) http://www.pjcj.net

# This software is free.  It is licensed under the same terms as Perl itself.

use 5.18.2;
use warnings;

use Data::Dumper;
use Getopt::Long;

my $Defaults = {
    debug   => 0,
    verbose => 0,
};

$Data::Dumper::Indent   = 1;
$Data::Dumper::Purity   = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Deparse  = 1;

our $O = {};
sub get_options {
    my $o = {};
    die "Bad option" unless
        GetOptions($o, qw(
            conf=s
            debug!
            verbose!
        ));

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
    print "Options: ", Dumper $O if $O->{verbose};
}

sub main {
    get_options;

    0
}

main

__END__

=head1 NAME

xxx - ...

=head1 SYNOPSIS

 xxx

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

Copyright 2016, Paul Johnson (paul@pjcj.net) http://www.pjcj.net

This software is free.  It is licensed under the same terms as Perl itself.

=cut
