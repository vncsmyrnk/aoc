use strict;
use warnings;

system("tr '\n' ' ' <input.txt >/tmp/input-concatenated.txt");

open(my $fh, '<', '/tmp/input-concatenated.txt') or die "Failed to read generated input file. $!";

my $total_count = 0;

while (my $line = <$fh>) {
  while ($line =~ /mul\((\d+),(\d+)\)/g) {
    $total_count += $1 * $2;
  }

  while ($line =~ /don't\(\)(.*?)do\(\)/g) {
    my $between = $1;

    while ($between =~ /mul\((\d+),(\d+)\)/g) {
      $total_count -= $1 * $2;
    }
  }
}

print "$total_count\n";
close($fh);
