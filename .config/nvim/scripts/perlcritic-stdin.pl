#!/usr/bin/env perl

# Run Perl::Critic on source read from STDIN while reporting it under the real
# filename passed via --file.  Injecting the filename into the PPI document lets
# filename-based policies such as RequireFilenameMatchesPackage work on unsaved
# buffer content, matching how PerlNavigator lints live.  Used by the Neovim
# nvim-lint perlcritic linter.

use strict;
use warnings;

use Getopt::Long qw( GetOptions );
use PPI          ();
use Perl::Critic ();

my ($file, $profile);

GetOptions("file=s" => \$file, "profile=s" => \$profile);

my $source = do { local $/; <STDIN> };
exit 0 unless defined $source && length $source;

my $doc = PPI::Document->new(\$source) or exit 0;
$doc->{filename} = $file if defined $file && length $file;

my %args;
$args{"-profile"} = $profile
  if defined $profile && length $profile && -f $profile;

my $critic = Perl::Critic->new(%args);
Perl::Critic::Violation::set_format("%f:%l:%c:%s:[%p] %m\n");
print $_->to_string for $critic->critique($doc);
