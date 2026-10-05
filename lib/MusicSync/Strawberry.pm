package MusicSync::Strawberry;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use DBD::SQLite        ();
use DBI                ();
use Encode             qw( decode_utf8 );
use Exporter           qw( import );
use Unicode::Normalize qw( NFC );
use URI::Escape        qw( uri_unescape );
use UUID::Tiny         ();

our @EXPORT_OK = qw(
  collection_songs     default_db
  open_db              plex_scale
  replace_playlist     strawberry_items
  strawberry_playlists strawberry_running
  update_ratings
);

sub default_db () {
  $^O eq "darwin"
    ? "$ENV{HOME}/Library/Application Support/strawberry/strawberry"
    . "/strawberry.db"
    : "$ENV{HOME}/.local/share/strawberry/strawberry/strawberry.db"
}

sub open_db ($path, $write = 0) {
  my $flags
    = $write ? DBD::SQLite::OPEN_READWRITE() : DBD::SQLite::OPEN_READONLY();
  DBI->connect(
    "dbi:SQLite:dbname=$path",
    "", "", {
      RaiseError        => 1,
      PrintError        => 0,
      sqlite_unicode    => 1,
      sqlite_open_flags => $flags,
    }
  )
}

sub strawberry_running () { system("pgrep", "-xq", "strawberry") == 0 }

sub directories ($dbh) {
  [ map $_->[0], $dbh->selectall_arrayref("SELECT path FROM directories")->@* ]
}

sub decode_url ($url) {
  my ($path) = $url =~ m|^file://(.*)$| or return;
  decode_utf8(uri_unescape($path))
}

sub relative_path ($dirs, $path) {
  return undef unless defined $path;
  for my $dir (@$dirs) {
    return NFC(substr $path, length($dir) + 1) if index($path, "$dir/") == 0;
  }
  undef
}

sub collection_songs ($dbh) {
  my $dirs = directories($dbh);
  my $rows = $dbh->selectall_arrayref(
    "SELECT ROWID, url, rating FROM songs WHERE unavailable = 0");
  my %songs;
  for my $row (@$rows) {
    my ($id, $url, $rating) = @$row;
    my $path = decode_url($url);
    my $rel  = relative_path($dirs, $path) // next;
    $songs{$rel} = { id => $id, path => $path, rel => $rel, rating => $rating };
  }
  \%songs
}

sub strawberry_playlists ($dbh) {
  my $rows = $dbh->selectall_arrayref(
    "SELECT ROWID, name FROM playlists WHERE is_favorite != 0 ORDER BY name");
  [ map { id => $_->[0], name => $_->[1] }, @$rows ]
}

sub strawberry_items ($dbh, $playlist_id) {
  my $dirs = directories($dbh);
  my $rows = $dbh->selectall_arrayref(
    "SELECT url, title, artist FROM playlist_items WHERE playlist = ?
     ORDER BY ROWID", undef, $playlist_id
  );
  my @items;
  for my $row (@$rows) {
    my ($url, $title, $artist) = @$row;
    my $path = decode_url($url);
    push @items, {
        path   => $path,
        rel    => relative_path($dirs, $path),
        title  => $title,
        artist => $artist,
      };
  }
  \@items
}

sub song_columns ($dbh) {
  my $names = sub ($table) {
    [ map $_->[1], $dbh->selectall_arrayref("PRAGMA table_info($table)")->@* ]
  };
  my %item = map { $_ => 1 } $names->("playlist_items")->@*;
  [ grep $item{$_}, $names->("songs")->@* ]
}

sub playlist_id ($dbh, $name) {
  my ($id) = $dbh->selectrow_array(
    "SELECT ROWID FROM playlists WHERE name = ?",
    undef, $name
  );
  if (defined $id) {
    $dbh->do("UPDATE playlists SET is_favorite = 1 WHERE ROWID = ?", undef,
      $id);
    return $id;
  }
  $dbh->do(
    "INSERT INTO playlists (name, ui_order, is_favorite) VALUES (?, -1, 1)",
    undef, $name
  );
  $dbh->sqlite_last_insert_rowid
}

sub replace_playlist ($dbh, $name, $song_ids) {
  my $columns = join ", ", song_columns($dbh)->@*;
  $dbh->begin_work;
  my $id = playlist_id($dbh, $name);
  $dbh->do("DELETE FROM playlist_items WHERE playlist = ?", undef, $id);
  my $insert = $dbh->prepare(
    "INSERT INTO playlist_items (playlist, type, uuid, collection_id, $columns)
     SELECT ?, 2, ?, ROWID, $columns FROM songs WHERE ROWID = ?"
  );
  for my $song_id (@$song_ids) {
    my $uuid = UUID::Tiny::create_uuid_as_string(UUID::Tiny::UUID_V4());
    $insert->execute($id, $uuid, $song_id);
  }
  $dbh->commit;
}

sub plex_scale ($rating) {
  defined $rating && $rating > 0 ? int($rating * 10 + 0.5) : undef
}

sub update_ratings ($dbh, $ratings) {
  $dbh->begin_work;
  my $update = $dbh->prepare("UPDATE songs SET rating = ? WHERE ROWID = ?");
  $update->execute($ratings->{$_}, $_) for keys %$ratings;
  $dbh->commit;
}

1;

__END__

=head1 NAME

MusicSync::Strawberry - read and write the Strawberry database

=head1 SYNOPSIS

 use MusicSync::Strawberry qw( open_db collection_songs );

 my $dbh   = open_db(default_db());
 my $songs = collection_songs($dbh);

=head1 DESCRIPTION

Opens the SQLite database Strawberry keeps, lists the songs of the
collection by path relative to its directories, and reads and replaces the
favourite playlists.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
