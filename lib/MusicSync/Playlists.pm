package MusicSync::Playlists;

use 5.28.0;
use warnings;
use utf8;
use feature "signatures";
no warnings "experimental::signatures";

use Encode             qw( decode_utf8 encode_utf8 );
use Exporter           qw( import );
use File::Basename     qw( dirname );
use File::Copy         qw( copy );
use File::Find         qw( find finddepth );
use File::Path         qw( make_path );
use File::Spec         ();
use Unicode::Normalize qw( NFC );

use MusicSync::Match qw( local_rel local_song plex_rel roots track_key );
use MusicSync::Plex  qw(
  default_section      plex_add_items
  plex_create_playlist plex_library_tracks
  plex_move_item       plex_playlist_items
  plex_playlists       plex_remove_item
  plex_section
);
use MusicSync::Strawberry qw(
  collection_songs replace_playlist
  strawberry_items strawberry_playlists
  strawberry_running
);

our @EXPORT_OK = qw(
  export_playlists list_playlists plan_changes plan_moves
  pull_playlists   push_playlists reorder_plan report
  sync_playlist
);

sub plural ($n, $word) { "$n $word" . ($n == 1 ? "" : "s") }

sub list_playlists ($plex, $dbh) {
  print "Plex playlists:\n";
  for my $p (plex_playlists($plex)->@*) {
    my $smart = $p->{smart} ? ", smart" : "";
    print "  $p->{title} (" . plural($p->{count}, "track") . "$smart)\n";
  }
  print "Strawberry playlists:\n";
  for my $p (strawberry_playlists($dbh)->@*) {
    my ($n) = $dbh->selectrow_array(
      "SELECT COUNT(*) FROM playlist_items WHERE playlist = ?", undef,
      $p->{id}
    );
    print "  $p->{name} (" . plural($n, "track") . ")\n";
  }
}

sub notes ($p) {
  my @notes;
  push @notes, "smart" if $p->{smart};
  push @notes,
    $p->{created} ? "created on Plex" : "not on Plex, nothing to create"
    if defined $p->{created};
  push @notes, "skipped, $p->{skipped}" if $p->{skipped};
  push @notes, map "$_ $p->{$_}", grep defined $p->{$_},
    qw( removed added moved repeated );
  @notes ? " (" . join(", ", @notes) . ")" : ""
}

sub roots_line ($roots) {
  return "No Plex root found, so nothing can match\n"
    unless defined $roots->{plex};
  my $local
    = $roots->{local} eq ""
    ? "the collection root"
    : "collection folder $roots->{local}";
  "Plex root $roots->{plex} maps to $local\n"
}

sub report ($summary, $opts) {
  print roots_line($summary->{roots}) if $summary->{roots};
  for my $p ($summary->{playlists}->@*) {
    my $total = $p->{matched} + $p->{unmatched}->@* + ($p->{repeated} // 0);
    print "$p->{name}: $p->{matched} of "
      . plural($total, "track")
      . notes($p) . "\n";
    print "  not found: $_\n" for $p->{unmatched}->@*;
  }
  print "Skipped smart playlists: @{$summary->{skipped}}\n"
    if ($summary->{skipped} // [])->@*;
  print "Copied "
    . plural($summary->{copied}, "file")
    . ", removed $summary->{removed}\n"
    if defined $summary->{copied};
  print "Dry run, nothing changed\n" if $opts->{dry_run};
}

sub selected ($list, $field, $names) {
  return $list unless $names && @$names;
  my %want = map { $_ => 1 } @$names;
  [ grep $want{ $_->{$field} }, @$list ]
}

sub label ($item) { "$item->{artist} - $item->{title}" }

sub partition ($items, $match) {
  my (@found, @unmatched);
  for my $item (@$items) {
    my $value = $match->($item);
    defined $value ? push @found, $value : push @unmatched, label($item);
  }
  (\@found, \@unmatched)
}

sub matched_playlists ($plex, $songs, $opts, $playlists) {
  my %items
    = map { $_->{id} => plex_playlist_items($plex, $_->{id}) } @$playlists;
  my $roots = roots($opts, [ map @$_, values %items ], $songs);
  my @matched;
  for my $playlist (@$playlists) {
    my ($found, $unmatched) = partition(
      $items{ $playlist->{id} },
      sub ($item) { local_song($songs, $roots, $item->{path}) }
    );
    push @matched, {
        name      => $playlist->{title},
        smart     => $playlist->{smart},
        found     => $found,
        unmatched => $unmatched,
      };
  }
  ($roots, \@matched)
}

sub pull_playlists ($plex, $dbh, $opts) {
  die "Quit Strawberry before pulling playlists\n"
    if !$opts->{dry_run} && strawberry_running();
  my $songs     = collection_songs($dbh);
  my $playlists = selected(plex_playlists($plex), "title", $opts->{playlists});
  my @wanted    = grep $opts->{smart} || !$_->{smart}, @$playlists;
  my @skipped   = grep !$opts->{smart} && $_->{smart}, @$playlists;
  my ($roots, $matched) = matched_playlists($plex, $songs, $opts, \@wanted);
  my $summary = {
    roots     => $roots,
    skipped   => [ map $_->{title}, @skipped ],
    playlists => [],
  };

  for my $playlist (@$matched) {
    my $found = $playlist->{found};
    my %seen;
    my $ids      = [ grep !$seen{$_}++, map $_->{id}, @$found ];
    my $repeated = @$found - @$ids;
    replace_playlist($dbh, $playlist->{name}, $ids) unless $opts->{dry_run};
    push $summary->{playlists}->@*, {
        name      => $playlist->{name},
        matched   => scalar @$ids,
        unmatched => $playlist->{unmatched},
        $playlist->{smart} ? (smart    => 1)         : (),
        $repeated          ? (repeated => $repeated) : (),
      };
  }
  $summary
}

sub plan_changes ($current, $desired) {
  my (%need, @remove, @add);
  $need{$_}++ for @$desired;
  for my $item (@$current) {
    my $key = $item->{key};
    ($need{$key} // 0) > 0 ? $need{$key}-- : push @remove, $item->{item_id};
  }
  for my $key (@$desired) {
    push @add, $key if $need{$key}-- > 0;
  }
  { remove => \@remove, add => \@add }
}

sub add_keys ($plex, $id, $keys) {
  my (%remaining, %seen);
  $remaining{$_}++ for @$keys;
  my @order = grep !$seen{$_}++, @$keys;
  while (my @batch = grep $remaining{$_}-- > 0, @order) {
    plex_add_items($plex, $id, \@batch);
  }
}

sub plan_moves ($current, $desired) {
  my @order = @$current;
  my @moves;
  for my $i (0 .. $#$desired) {
    my $id = $desired->[$i];
    next if $order[$i] eq $id;
    @order = grep $_ ne $id, @order;
    splice @order, $i, 0, $id;
    push @moves, [ $id, $i ? $desired->[ $i - 1 ] : undef ];
  }
  \@moves
}

sub reorder_plan ($items, $keys) {
  my %pool;
  push $pool{ $_->{key} }->@*, $_->{item_id} for @$items;
  my @desired = grep defined, map shift(($pool{$_} // [])->@*), @$keys;
  plan_moves([ map $_->{item_id}, @$items ], \@desired)
}

sub sync_playlist ($plex, $id, $current, $keys, $dry_run) {
  my $changes = plan_changes($current, $keys);
  my $items   = $current;
  if ($dry_run) {
    my %removed = map { $_ => 1 } $changes->{remove}->@*;
    $items = [ grep !$removed{ $_->{item_id} }, @$current ];
  } elsif ($changes->{remove}->@* || $changes->{add}->@*) {
    plex_remove_item($plex, $id, $_) for $changes->{remove}->@*;
    add_keys($plex, $id, $changes->{add});
    $items = plex_playlist_items($plex, $id);
  }
  my $moves = reorder_plan($items, $keys);
  plex_move_item($plex, $id, @$_) for $dry_run ? () : @$moves;
  {
    removed => scalar $changes->{remove}->@*,
    added   => scalar $changes->{add}->@*,
    moved   => scalar @$moves,
  }
}

sub plex_changes ($plex, $target, $name, $keys, $current, $dry_run) {
  return { skipped => "smart playlist on Plex" } if $target && $target->{smart};
  return sync_playlist($plex, $target->{id}, $current, $keys, $dry_run)
    if $target;
  plex_create_playlist($plex, $name, $keys) if @$keys && !$dry_run;
  { created => @$keys ? 1 : 0 }
}

sub push_playlists ($plex, $dbh, $opts) {
  my $songs = collection_songs($dbh);
  # uncoverable condition false note:the default section name is always set
  my $section = plex_section($plex, $opts->{section} // default_section());
  my $tracks  = plex_library_tracks($plex, $section);
  my $roots   = roots($opts, $tracks, $songs);
  my %key_for;

  for my $track (@$tracks) {
    my $rel = plex_rel($roots->{plex}, $track->{path}) // next;
    $key_for{$rel} = $track->{key};
  }
  my %on_plex = map { $_->{title} => $_ } plex_playlists($plex)->@*;
  my $summary = { roots => $roots, playlists => [] };
  for my $playlist (
    selected(strawberry_playlists($dbh), "name", $opts->{playlists})->@*
  ) {
    my $items   = strawberry_items($dbh, $playlist->{id});
    my $target  = $on_plex{ $playlist->{name} };
    my $current = $target
      && !$target->{smart} ? plex_playlist_items($plex, $target->{id}) : [];
    my %present = map { $_->{key} => 1 } @$current;
    my ($keys, $unmatched) = partition(
      $items,
      sub ($item) {
        my $rel = local_rel($roots->{local}, $item->{rel}) // return;
        track_key(\%key_for, \%present, $opts, $rel)
      }
    );
    my $changes = @$keys || !@$items
      ? plex_changes(
        $plex, $target, $playlist->{name}, $keys, $current, $opts->{dry_run}
      )
      : { skipped => "no tracks matched" };
    push $summary->{playlists}->@*, {
        name      => $playlist->{name},
        matched   => scalar @$keys,
        unmatched => $unmatched,
        %$changes,
      };
  }
  $summary
}

sub fs ($path) { encode_utf8($path) }

sub m3u_name ($name) {
  (my $file = $name) =~ s{[\\/:*?"<>|]}{_}g;
  "$file.m3u8"
}

sub write_m3u ($path, $entries) {
  open my $fh, ">:encoding(UTF-8)", fs($path)
    or die "Cannot write $path ($!)\n";
  print $fh "#EXTM3U\n";
  print $fh "$_\n" for @$entries;
  # uncoverable branch true note:close fails only on an I/O error
  close $fh or die "Cannot close $path ($!)\n";
}

sub stale ($from, $to) {
  my $size = -s fs($from) // die "Missing file $from\n";
  !-e fs($to) || -s fs($to) != $size
}

sub copy_track ($from, $to) {
  make_path(fs(dirname $to));
  copy(fs($from), fs($to)) or die "Cannot copy $from to $to ($!)\n";
}

sub stale_files ($dir, $keep) {
  return [] unless -d fs($dir);
  my @stale;
  my $wanted = sub () {
    return unless -f;
    my $rel = NFC(decode_utf8(File::Spec->abs2rel($_, fs($dir))));
    return if $keep->{$rel} || $rel =~ m!(^|/)\.!;
    push @stale, $_;
  };
  find({ wanted => $wanted, no_chdir => 1 }, fs($dir));
  \@stale
}

sub remove_files ($dir, $files) {
  for my $file (@$files) {
    unlink $file or die "Cannot remove $file ($!)\n";
  }
  my $prune = sub () { rmdir $_ if -d && $_ ne fs($dir) };
  finddepth({ wanted => $prune, no_chdir => 1 }, fs($dir));
}

sub strawberry_exports ($dbh, $opts) {
  my @exports;
  for my $playlist (
    selected(strawberry_playlists($dbh), "name", $opts->{playlists})->@*
  ) {
    my ($found, $unmatched) = partition(
      strawberry_items($dbh, $playlist->{id}),
      sub ($item) { defined $item->{rel} ? $item : undef }
    );
    push @exports,
      { name => $playlist->{name}, found => $found, unmatched => $unmatched };
  }
  \@exports
}

sub plex_exports ($plex, $dbh, $opts) {
  my $playlists = selected(plex_playlists($plex), "title", $opts->{playlists});
  my $smart     = [ grep $_->{smart}, @$playlists ];
  matched_playlists($plex, collection_songs($dbh), $opts, $smart)
}

sub export_playlists ($dbh, $dir, $opts, $plex = undef) {
  make_path(fs($dir)) unless $opts->{dry_run};
  my $summary = { playlists => [], copied => 0, removed => 0 };
  my $exports = strawberry_exports($dbh, $opts);
  if ($plex) {
    my ($roots, $smart) = plex_exports($plex, $dbh, $opts);
    $summary->{roots} = $roots if @$smart;
    push @$exports, @$smart;
  }
  my (%wanted, %keep);
  for my $export (@$exports) {
    my $found = $export->{found};
    $wanted{ $_->{rel} } = $_->{path} for @$found;
    my $m3u = m3u_name($export->{name});
    $keep{$m3u} = 1;
    write_m3u("$dir/$m3u", [ map $_->{rel}, @$found ]) unless $opts->{dry_run};
    push $summary->{playlists}->@*, {
        name      => $export->{name},
        matched   => scalar @$found,
        unmatched => $export->{unmatched},
        $export->{smart} ? (smart => 1) : (),
      };
  }
  for my $rel (sort keys %wanted) {
    next unless stale($wanted{$rel}, "$dir/$rel");
    copy_track($wanted{$rel}, "$dir/$rel") unless $opts->{dry_run};
    $summary->{copied}++;
  }
  return $summary if $opts->{playlists};
  my $stale = stale_files($dir, { %wanted, %keep });
  remove_files($dir, $stale) unless $opts->{dry_run};
  $summary->{removed} = @$stale;
  $summary
}

1;

__END__

=head1 NAME

MusicSync::Playlists - copy playlists between Plex, Strawberry and devices

=head1 SYNOPSIS

 use MusicSync::Playlists qw( pull_playlists report );

 report(pull_playlists($plex, $dbh, $opts), $opts);

=head1 DESCRIPTION

Pulls Plex playlists into Strawberry, pushes Strawberry favourites to Plex,
exports them with their files for a device, and prints the report of what
each run did.

=head1 LICENCE

Copyright 2026, Paul Johnson (paul@pjcj.net)

=cut
