package %MODULE%;

use 5.18.2;
use warnings;
use utf8::all;

use Moose;
use namespace::autoclean;

# implementation

__PACKAGE__->meta->make_immutable;

"
Careful, now!
"

__END__

=head1 NAME

%MODULE% - Do some %MODULE%

=head1 SYNOPSIS

 use %MODULE%;

=head1 DESCRIPTION

This module ...

=head1 REQUIREMENTS

=head1 OPTIONS

=head1 ENVIRONMENT

=head1 SEE ALSO

=head1 BUGS

=head1 LICENCE

Copyright %YEAR%, Paul Johnson (paul@pjcj.net)

=cut
