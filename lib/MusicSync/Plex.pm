package MusicSync::Plex;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Encode      qw( decode_utf8 );
use Exporter    qw( import );
use HTTP::Tiny  ();
use URI::Escape qw( uri_escape_utf8 );
use XML::Simple ();

our @EXPORT_OK = qw(
  chars               default_section
  default_server      plex_add_items
  plex_client         plex_create_playlist
  plex_library_tracks plex_machine_id
  plex_move_item      plex_playlist_items
  plex_playlists      plex_rate
  plex_remove_item    plex_request
  plex_section        read_password
);

sub parse_xml ($xml, @force) {
  XML::Simple->new->XMLin($xml, KeyAttr => {}, ForceArray => [@force])
}

my $Client_headers = {
  "X-Plex-Client-Identifier" => "music_sync",
  "X-Plex-Product"           => "music_sync",
  "X-Plex-Version"           => "1.0",
};

sub request ($plex, $method, $url) {
  print STDERR "$method $url\n" if $plex->{debug};
  my $headers = {
    %$Client_headers,
    "X-Plex-Token" => $plex->{token},
    Accept         => "application/xml",
  };
  my $response = $plex->{http}->request($method, $url, { headers => $headers });
  die "$method $url failed with $response->{status} $response->{reason}\n"
    unless $response->{success};
  $response->{content}
}

sub plex_request ($plex, $method, $path) {
  request($plex, $method, "$plex->{server}$path")
}

sub chars ($text) {
  return "" unless defined $text;
  utf8::is_utf8($text) ? $text : decode_utf8($text)
}

sub plex_playlists ($plex) {
  my $data = parse_xml(plex_request($plex, "GET", "/playlists"), "Playlist");
  [
    map +{
      id    => $_->{ratingKey},
      title => chars($_->{title}),
      smart => $_->{smart} ? 1 : 0,
      count => $_->{leafCount} // 0,
    },
    grep { ($_->{playlistType} // "") eq "audio" }
      ($data->{Playlist} // [])->@*,
  ]
}

sub plex_sign_in ($http, $username, $password) {
  my $form     = { "user[login]" => $username, "user[password]" => $password };
  my $response = $http->post_form(
    "https://plex.tv/users/sign_in.xml", $form,
    { headers => $Client_headers }
  );
  die "Plex sign in failed with $response->{status} $response->{reason}\n"
    unless $response->{success};
  parse_xml($response->{content})->{authToken}
    // die "Plex sign in returned no token\n"
}

sub read_password () {
  print "Plex password: ";
  system "stty", "-echo";
  chomp(my $password = STDIN->getline // "");
  system "stty", "echo";
  print "\n";
  $password
}

sub password ($opts) {
  # uncoverable condition false note:read_password never returns undef
  $opts->{password} // read_password()
}

sub plex_token ($opts, $http) {
  # uncoverable condition false note:plex_sign_in never returns undef
  $opts->{token} // plex_sign_in($http, $opts->{username}, password($opts))
}

sub default_server () { "Wezflix" }

sub plex_servers ($plex) {
  my $url  = "https://plex.tv/api/v2/resources?includeHttps=1&includeRelay=1";
  my $data = parse_xml(request($plex, "GET", $url), "resource", "connection");
  [ grep { ($_->{provides} // "") =~ /\bserver\b/ }
    ($data->{resource} // [])->@* ]
}

sub plex_find_server ($plex, $name) {
  my $servers  = plex_servers($plex);
  my ($server) = grep { $_->{name} eq $name } @$servers;
  my $names    = join(", ", map $_->{name}, @$servers) || "none";
  die "No Plex server called $name (found $names)\n" unless $server;
  my ($best)
    = sort { $a->{relay} <=> $b->{relay} || $a->{local} <=> $b->{local} }
    ($server->{connections}{connection} // [])->@*;
  die "Plex server $name has no connections\n" unless $best;
  $best->{uri}
}

sub plex_server ($plex, $server) {
  return $server =~ s|/$||r if $server =~ m|^https?://|;
  plex_find_server($plex, $server)
}

sub plex_machine_id ($plex) {
  my $data = parse_xml(plex_request($plex, "GET", "/identity"));
  # uncoverable mcdc note:die never yields a value
  $data->{machineIdentifier} // die "Plex sent no machine identifier\n"
}

sub plex_user_token ($plex, $user_id) {
  $plex->{machine_id} = plex_machine_id($plex);
  my $url  = "https://plex.tv/api/servers/$plex->{machine_id}/shared_servers";
  my $data = parse_xml(request($plex, "GET", $url), "SharedServer");
  my ($server)
    = grep { ($_->{userID} // "") eq $user_id }
    ($data->{SharedServer} // [])->@*;
  # uncoverable mcdc note:die never yields a value
  ($server // {})->{accessToken}
    // die "No access token for Plex user $user_id\n"
}

sub plex_client ($opts, $http = undef) {
  die "Use --token or --username to sign in to Plex\n"
    unless $opts->{token} || $opts->{username};
  # uncoverable condition false note:HTTP::Tiny->new never returns undef
  $http //= HTTP::Tiny->new(timeout => 60, agent => "music_sync/1.0",
    verify_SSL => 1);
  my $plex = {
    http  => $http,
    token => plex_token($opts, $http),
    debug => $opts->{debug},
  };
  # uncoverable condition false note:the default server name is always set
  $plex->{server} = plex_server($plex, $opts->{server} // default_server());
  $plex->{token}  = plex_user_token($plex, $opts->{user}) if $opts->{user};
  $plex
}

sub track_path ($track) {
  my $part = $track->{Media}[0]{Part}[0] or return undef;
  chars($part->{file})
}

sub plex_playlist_items ($plex, $id) {
  my $data = parse_xml(
    plex_request($plex, "GET", "/playlists/$id/items"),
    qw( Track Media Part )
  );
  [
    map +{
      item_id => $_->{playlistItemID},
      key     => $_->{ratingKey},
      path    => track_path($_),
      title   => chars($_->{title}),
      artist  => chars($_->{grandparentTitle}),
    },
    ($data->{Track} // [])->@*,
  ]
}

sub default_section () { "mp3" }

sub music_sections ($plex) {
  my $data
    = parse_xml(plex_request($plex, "GET", "/library/sections"), "Directory");
  [ grep $_->{type} eq "artist", ($data->{Directory} // [])->@* ]
}

sub plex_section ($plex, $name) {
  # uncoverable condition false note:the default section name is always set
  $name //= default_section();
  my $sections  = music_sections($plex);
  my ($section) = grep $_->{title} eq $name, @$sections;
  my $names     = join(", ", map $_->{title}, @$sections) || "none";
  die "No Plex music section called $name (found $names)\n" unless $section;
  $section->{key}
}

sub plex_library_tracks ($plex, $section) {
  my $data = parse_xml(
    plex_request($plex, "GET", "/library/sections/$section/all?type=10"),
    qw( Track Media Part )
  );
  my @tracks;
  for my $track (($data->{Track} // [])->@*) {
    my $path = track_path($track) // next;
    push @tracks, {
        key    => $track->{ratingKey},
        path   => $path,
        rating => $track->{userRating},
      };
  }
  \@tracks
}

sub plex_rate ($plex, $key, $rating) {
  plex_request($plex, "PUT",
    "/:/rate?key=$key&identifier=com.plexapp.plugins.library&rating=$rating");
}

sub plex_remove_item ($plex, $id, $item_id) {
  plex_request($plex, "DELETE", "/playlists/$id/items/$item_id");
}

sub library_uri ($plex, $keys) {
  # uncoverable condition false note:plex_machine_id never returns undef
  $plex->{machine_id} //= plex_machine_id($plex);
  my $metadata = join ",", @$keys;
  uri_escape_utf8("server://$plex->{machine_id}/com.plexapp.plugins.library"
    . "/library/metadata/$metadata")
}

sub plex_add_items ($plex, $id, $keys) {
  plex_request(
    $plex, "PUT", "/playlists/$id/items?uri=" . library_uri($plex, $keys)
  );
}

sub plex_move_item ($plex, $id, $item_id, $after) {
  my $query = defined $after ? "?after=$after" : "";
  plex_request($plex, "PUT", "/playlists/$id/items/$item_id/move$query");
}

sub plex_create_playlist ($plex, $title, $keys) {
  my $query = join "&", "type=audio", "smart=0",
    "title=" . uri_escape_utf8($title), "uri=" . library_uri($plex, $keys);
  my $data
    = parse_xml(plex_request($plex, "POST", "/playlists?$query"), "Playlist");
  $data->{Playlist}[0]{ratingKey}
}

1;

__END__

=head1 NAME

MusicSync::Plex - talk to plex.tv and a Plex server

=head1 SYNOPSIS

 use MusicSync::Plex qw( plex_client plex_playlists );

 my $plex = plex_client({ username => $email, password => $password });
 my $playlists = plex_playlists($plex);

=head1 DESCRIPTION

Signs in to plex.tv, finds the server, and reads and changes its audio
playlists and library tracks over the XML API.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
