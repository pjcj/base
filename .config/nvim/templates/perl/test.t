#!/usr/bin/perl

use 5.18.2;
use warnings;
use utf8::all;

use Carp::Always;
use Encode;
use Test::More;
use Unicode::Normalize qw( NFC NFD NFKC NFKD );

binmode $_, ":encoding(UTF-8)" for *STDIN, *STDOUT, *STDERR;

sub main {
    is 1, 1, "First test";
}

main;
done_testing;

__END__

=head1 LICENCE

Copyright 2016, Paul Johnson (paul@pjcj.net) http://www.pjcj.net

This software is free.  It is licensed under the same terms as Perl itself.

=cut
