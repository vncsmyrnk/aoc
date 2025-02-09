use strict;
use warnings;

open(my $fh, '<', 'input.txt') or die "input file required. Check project or AOC docs for more information about how to to get it. $!";

my $count = 0;

while (my $line = <$fh>) {
  while ($line =~ /mul\((\d+),(\d+)\)/g) {
    $count += $1 * $2;
  }
}

print "$count\n";
close($fh);
