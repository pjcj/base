package FakeHttp;

use 5.28.0;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use Encode qw( encode_utf8 );

sub new ($class, $responses = {}) {
  bless { responses => $responses, calls => [] }, $class
}

sub request ($self, $method, $url, $options = {}) {
  my ($path) = $url =~ m|^https?://[^/]+(.*)$|;
  push $self->{calls}->@*, "$method $path";
  $self->{headers} = $options->{headers};
  my $content = $self->{responses}{"$method $path"};
  $content = shift @$content if ref $content;
  return { success => 1, status => 200, content => encode_utf8($content) }
    if defined $content;
  { success => 0, status => 404, reason => "Not Found", content => "" }
}

sub post_form ($self, $url, $form, @) {
  my $login = $form->{"user[login]"};
  push $self->{calls}->@*, "POST $url $login";
  my $content = $self->{responses}{"POST $url"};
  return { success => 1, status => 201, content => encode_utf8($content) }
    if defined $content;
  { success => 0, status => 401, reason => "Unauthorized", content => "" }
}

1;

__END__

=head1 NAME

FakeHttp - a stand-in for HTTP::Tiny in the music_sync tests

=head1 SYNOPSIS

 my $http = FakeHttp->new({ "GET /playlists" => $xml });
 $http->request("GET", "http://plex.test:32400/playlists");

=head1 DESCRIPTION

Answers each request from a table keyed by method and path and records the
calls made. A value that is an array reference serves one entry per call.
An unknown request gets a 404 and an unknown sign-in form a 401.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
