#!/usr/bin/perl

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
use open qw( :std :utf8 );

use Encode  qw( decode_utf8 encode_utf8 );
use FindBin ();
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test2::V0 qw( dies done_testing is like mock ok subtest );

use FakeHttp        ();
use MusicSync::Plex qw(
  chars               default_section
  plex_client         plex_library_albums
  plex_library_tracks plex_machine_id
  plex_move_item      plex_playlist_items
  plex_playlists      plex_rate
  plex_request        plex_section
  read_password
);
use MusicSync::Test qw(
  albums_xml    capture identity_xml items_xml
  playlists_xml plex    sections_xml tracks_xml
);

no warnings "experimental::signatures";

subtest "plex playlists" => sub {
  my $plex = plex({ "GET /playlists" => playlists_xml() });
  is plex_playlists($plex), [
      { id => 10, title => "Trance", smart => 0, count => 3 },
      { id => 12, title => "Recent", smart => 1, count => 5 },
      { id => 13, title => "Chill",  smart => 0, count => 1 },
    ],
    "audio playlists in server order";
};

subtest "plex playlist items" => sub {
  my $plex = plex({ "GET /playlists/10/items" => items_xml() });
  is plex_playlist_items($plex, 10), [
      {
        item_id => 1001,
        key     => 101,
        path    => "/srv/music/Artist/Album/01 Song A.mp3",
        title   => "Song A",
        artist  => "Artist",
      }, {
        item_id => 1002,
        key     => 102,
        path    => "/srv/music/Artist/Album/02 Song B.mp3",
        title   => "Song B",
        artist  => "Artist",
      }, {
        item_id => 1003,
        key     => 101,
        path    => "/srv/music/Artist/Album/01 Song A.mp3",
        title   => "Song A",
        artist  => "Artist",
      },
    ],
    "items in order with duplicates kept";
};

subtest "plex library tracks" => sub {
  my $plex = plex({ "GET /library/sections/1/all?type=10" => tracks_xml() });
  is plex_library_tracks($plex, 1), [
      {
        key          => 101,
        path         => "/srv/music/Artist/Album/01 Song A.mp3",
        rating       => 8,
        guid         => "plex://track/a1",
        title        => "Song A",
        artist       => "Artist",
        track_artist => undef,
        album_key    => 201,
        duration     => 180000,
        bitrate      => 320,
        size         => 7200000,
      }, {
        key          => 102,
        path         => "/srv/music/Artist/Album/02 Song B.mp3",
        rating       => undef,
        guid         => "plex://track/b2",
        title        => "Song B",
        artist       => "Artist",
        track_artist => "Artist feat. Guest",
        album_key    => 201,
        duration     => 200000,
        bitrate      => 192,
        size         => 4800000,
      }, {
        key          => 103,
        path         => "/srv/music/Other/Album/01 Thé.mp3",
        rating       => undef,
        guid         => undef,
        title        => "Thé",
        artist       => "Other",
        track_artist => undef,
        album_key    => undef,
        duration     => undef,
        bitrate      => undef,
        size         => undef,
      },
    ],
    "tracks with files from the section";
  is $plex->{http}{calls}, ["GET /library/sections/1/all?type=10"],
    "reads the one section";
};

subtest "plex library albums" => sub {
  my $plex = plex({ "GET /library/sections/1/all?type=9" => albums_xml() });
  is plex_library_albums($plex, 1), {
      201 => {
        title  => "Album",
        artist => "Artist",
        year   => 1985,
        kinds  => ["Album"],
      },
      202 => {
        title  => "Best Of",
        artist => "Artist",
        year   => 1999,
        kinds  => [ "Album", "Compilation" ],
      },
      203 => {
        title  => "Hits",
        artist => "Various Artists",
        year   => 2001,
        kinds  => [ "Album", "Compilation", "DJ Mix" ],
      },
      204 =>
      { title => "Undated", artist => "Other", year => undef, kinds => [] },
    },
    "albums keyed by rating key with their kinds";
  is $plex->{http}{calls}, ["GET /library/sections/1/all?type=9"],
    "reads the one listing";
  my $none
    = plex({ "GET /library/sections/1/all?type=9" => qq(<MediaContainer/>) });
  is plex_library_albums($none, 1), {}, "no albums";
};

subtest "plex section" => sub {
  my $plex = plex({ "GET /library/sections" => sections_xml() });
  is default_section(), "mp3", "the default section";
  is plex_section($plex, "mp3"),  1, "the key of a music section by name";
  is plex_section($plex, undef),  1, "the default section when none is named";
  is plex_section($plex, "flac"), 3, "another music section";
  like dies { plex_section($plex, "Films") },
    qr/No Plex music section called Films \(found mp3, flac\)/,
    "a film section does not count";
  my $none
    = plex({ "GET /library/sections" => qq(<MediaContainer size="0"/>) });
  like dies { plex_section($none, "mp3") },
    qr/No Plex music section called mp3 \(found none\)/, "no music sections";
};

subtest "plex rate" => sub {
  my $call = "PUT /:/rate?key=101&identifier=com.plexapp.plugins.library"
    . "&rating=8";
  my $plex = plex({ $call => "" });
  plex_rate($plex, 101, 8);
  is $plex->{http}{calls}, [$call], "rates a track by key on the Plex scale";
};

subtest "plex request failure" => sub {
  my $plex = plex;
  like dies { plex_request($plex, "GET", "/missing") }, qr/404 Not Found/,
    "dies with the status";
};

subtest "plex client" => sub {
  my $sign_in = "POST https://plex.tv/users/sign_in.xml";
  my $http    = FakeHttp->new({ $sign_in => qq(<user authToken="secret"/>) });
  like dies { plex_client({ server => "http://x" }, $http) },
    qr/--token or --username/, "needs a way to authenticate";
  is plex_client({ server => "http://x/", token => "t", debug => 1 }, $http),
    { http => $http, server => "http://x", token => "t", debug => 1 },
    "uses a given token and trims the server slash";
  is plex_client(
    { server => "http://x", username => "me", password => "pw" }, $http
  )->{token}, "secret", "signs in with a username and password";
  is $http->{calls}, ["$sign_in me"], "posted the sign in form";
  my $mock = mock "MusicSync::Plex" =>
    (override => [ read_password => sub () { "pw" } ]);
  is plex_client({ server => "http://x", username => "me" }, $http)->{token},
    "secret", "prompts for the password";
  $http = FakeHttp->new;
  like dies {
    plex_client(
      { server => "http://x", username => "me", password => "pw" }, $http
    )
  }, qr/401 Unauthorized/, "reports a failed sign in";
  $http = FakeHttp->new({ $sign_in => "<user/>" });
  like dies {
    plex_client(
      { server => "http://x", username => "me", password => "pw" }, $http
    )
  }, qr/returned no token/, "reports a sign in without a token";
  ok plex_client({ server => "http://x", token => "t" })->{http}
    ->isa("HTTP::Tiny"), "builds a real client when none is given";

  my $shared = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <MediaContainer size="2">
    <SharedServer id="1" username="owner"/>
    <SharedServer id="2" userID="21" accessToken="usertok"/>
    </MediaContainer>
    XML
  $http = FakeHttp->new({
    "GET /identity"                          => identity_xml(),
    "GET /api/servers/abc123/shared_servers" =>
      [ $shared, qq(<MediaContainer size="0"/>) ],
  });
  my $user
    = plex_client({ server => "http://x", token => "t", user => 21 }, $http);
  is [ @$user{ qw( token machine_id ) } ], [ "usertok", "abc123" ],
    "swaps in the token of the given user";
  like dies {
    plex_client({ server => "http://x", token => "t", user => 99 }, $http)
  }, qr/No access token for Plex user 99/, "unknown user";

  my $resources = "GET /api/v2/resources?includeHttps=1&includeRelay=1";
  my $devices   = <<~XML;
    <?xml version="1.0" encoding="UTF-8"?>
    <resources>
    <resource name="Wezflix" provides="server">
    <connections>
    <connection uri="https://lan.plex.direct:32400" local="1" relay="0"/>
    <connection uri="https://wan.plex.direct:32400" local="0" relay="0"/>
    <connection uri="https://relay.plex.direct:8443" local="0" relay="1"/>
    </connections>
    </resource>
    <resource name="shadowfax" provides="server">
    <connections>
    <connection uri="https://lan2.plex.direct:32400" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Wezflix" provides="client,player">
    <connections>
    <connection uri="http://1.2.3.4:1" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Odd"/>
    </resources>
    XML
  $http = FakeHttp->new({ $resources => $devices });
  is plex_client({ token => "t" }, $http)->{server},
    "https://wan.plex.direct:32400",
    "finds Wezflix on plex.tv and prefers its direct internet connection";
  is $http->{headers}{"X-Plex-Client-Identifier"}, "music_sync",
    "sends the client identifier plex.tv requires";
  is plex_client({ token => "t", server => "shadowfax" }, $http)->{server},
    "https://lan2.plex.direct:32400",
    "finds a server by name and falls back to a LAN connection";
  like dies {
    plex_client({ token => "t", server => "Nope" }, $http)
  }, qr/No Plex server called Nope \(found Wezflix, shadowfax\)/,
    "unknown server name";
  $http = FakeHttp->new({ $resources => <<~XML });
    <resources>
    <resource name="Far" provides="server">
    <connections>
    <connection uri="https://relay.plex.direct:8443" local="0" relay="1"/>
    <connection uri="https://lan.plex.direct:32400" local="1" relay="0"/>
    </connections>
    </resource>
    <resource name="Off" provides="server"><connections/></resource>
    </resources>
    XML
  is plex_client({ token => "t", server => "Far" }, $http)->{server},
    "https://lan.plex.direct:32400", "prefers a LAN connection over the relay";
  like dies {
    plex_client({ token => "t", server => "Off" }, $http)
  }, qr/Plex server Off has no connections/, "server without connections";
  $http = FakeHttp->new({ $resources => "<resources/>" });
  like dies { plex_client({ token => "t" }, $http) },
    qr/No Plex server called Wezflix \(found none\)/, "no servers at all";
};

sub capture_stderr ($code) {
  my $err = "";
  {
    local *STDERR;
    open STDERR, ">:encoding(UTF-8)", \$err or die "Cannot capture STDERR ($!)";
    $code->();
    close STDERR or die "Cannot close STDERR ($!)";
  }
  decode_utf8($err)
}

subtest "edge cases" => sub {
  my $empty = qq(<MediaContainer size="0"/>);
  my $plex  = plex({
    "GET /playlists"                        => $empty,
    "GET /playlists/1/items"                => $empty,
    "GET /identity"                         => $empty,
    "PUT /playlists/1/items/5/move?after=4" => "",
  });
  is plex_playlists($plex),         [], "no playlists";
  is plex_playlist_items($plex, 1), [], "no items";
  like dies { plex_machine_id($plex) }, qr/machine identifier/, "no identity";
  plex_move_item($plex, 1, 5, 4);
  is $plex->{http}{calls}[-1], "PUT /playlists/1/items/5/move?after=4",
    "moves after an item";
  $plex = plex({ "GET /library/sections/1/all?type=10" => $empty });
  is plex_library_tracks($plex, 1), [],  "an empty music section";
  is chars(encode_utf8("é")),       "é", "decodes bytes";
  is chars(undef),                  "",  "empty for undef";

  $plex = plex({
    "GET /playlists" => qq(<MediaContainer size="2">
      <Playlist ratingKey="9" title="Bare" playlistType="audio"/>
      <Playlist ratingKey="8" title="Odd"/>
      </MediaContainer>),
  });
  is plex_playlists($plex),
    [ { id => 9, title => "Bare", smart => 0, count => 0 } ],
    "defaults for a playlist without a type or a count";

  $plex = plex({ "GET /identity" => identity_xml() });
  $plex->{debug} = 1;
  is capture_stderr(sub { plex_machine_id($plex) }),
    "GET http://plex.test:32400/identity\n", "debug shows each request";
};

sub with_terminal ($input, $code) {
  local *STDIN;
  open STDIN,     "<",  \$input     or die "Cannot fake STDIN ($!)";
  open my $saved, ">&", \*STDERR    or die "Cannot save STDERR ($!)";
  open STDERR,    ">",  "/dev/null" or die "Cannot silence STDERR ($!)";
  my $result = $code->();
  open STDERR, ">&", $saved or die "Cannot restore STDERR ($!)";
  $result
}

subtest "password prompt" => sub {
  my $password;
  my $out = with_terminal(
    "secret\n",
    sub {
      capture(sub { $password = read_password() })
    }
  );
  is $password, "secret", "reads the password";
  like $out, qr/Plex password:/, "prompts for it";
  with_terminal(
    "",
    sub {
      capture(sub { $password = read_password() })
    }
  );
  is $password, "", "empty password at the end of input";
};

done_testing;

__END__

=head1 NAME

music_sync_plex.t - tests for lib/MusicSync/Plex.pm

=head1 SYNOPSIS

 yath test t/music_sync_plex.t

=head1 DESCRIPTION

Drives the Plex functions with a fake HTTP client in place of plex.tv and
the server.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
