#!/usr/bin/perl -CSAD

use 5.18.2;
use warnings;
use utf8::all;

use Encode;
use Test::More;
use Unicode::Normalize qw( NFC NFD NFKC NFKD );

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

plan tests => 5;

is 1, 1, "First test";
