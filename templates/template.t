#!/usr/bin/perl

use 5.18.2;
use warnings;
use utf8::all;

use Carp::Always;
use Data::Printer deparse => 1;
use Encode;
use Getopt::Long;
use Path::Tiny;
use Test::More;
use Unicode::Normalize qw( NFC NFD NFKC NFKD );

sub main {
    is 1, 1, "First test";

    # implementation
}

main;
done_testing;

__END__

=head1 LICENCE

Copyright %YEAR%, Paul Johnson (paul@pjcj.net)

=cut
