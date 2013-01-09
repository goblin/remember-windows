#! /usr/bin/perl

# The script will move all the windows to positions specified by the input file

# usage: 
#   % restore <file>
# where <file> is a previous output of wmctrl -G -p -l

use strict;
use warnings;

my @old = map { chomp; $_ } <>;
my @cur = split /\n/, `wmctrl -G -p -l`;

sub parse_line {
	my ($line) = @_;

	my @vals = split / +/, $line;
	$vals[8] = join ' ', @vals[8 .. @vals-1];
	my @keys = qw(window_id desktop pid x y w h host title);

	return { map { $keys[$_] => $vals[$_] } (0..8) };
}

sub matches {
	my ($a, $b, $keys) = @_;

	foreach my $key (@$keys) {
		return 0 if($a->{$key} ne $b->{$key});
	}

	return 1;
}

sub output {
	my ($old, $cur, $txt) = @_;

	print "$cur->{window_id}/$cur->{title}\@$cur->{host} $txt\n";
}

sub move_cmd {
	my ($old) = @_;
	my $new_x = $old->{x} - 2;
	my $new_y = $old->{y} - 44; # this is how much window decorations take
	return "wmctrl -i -r $old->{window_id} -e 0,$new_x,$new_y,$old->{w},$old->{h}";
}

my %old_indexed;
foreach my $line (@old) {
	my $parsed = parse_line($line);
	$old_indexed{$parsed->{window_id}} = $parsed;
}

foreach my $win (@cur) {
	my $parsed = parse_line($win);
	if(my $old = $old_indexed{$parsed->{window_id}}) {
		if(matches($old, $parsed, [qw(desktop host title pid)])) {
			if(matches($old, $parsed, [qw(x y w h)])) {
				# output($old, $parsed, "is OK");
			} else {
				output($old, $parsed, "is wrong, moving");
				my $movecmd = move_cmd($old);
				`$movecmd`;
			}
		} else {
			output($old, $parsed, "doesn't match desktop/host/title");
			print "  $old->{desktop}\t$old->{pid}\t$old->{host}\t$old->{title}\n";
			print "  $parsed->{desktop}\t$parsed->{pid}\t$parsed->{host}\t$parsed->{title}\n";
			print "   would move with: " . move_cmd($old) . "\n";
		}
	} else {
		output($old, $parsed, "is a new window");
	}
}
