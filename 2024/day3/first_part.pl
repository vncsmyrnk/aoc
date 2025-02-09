use strict;
use warnings;

sub main {
  my $count = process_file('input.txt');
  print "$count\n";
}

sub process_file {
  my ($file_name) = @_;
  open(my $fh, '<', $file_name) or die "input file required. Check project or AOC docs for more information about how to to get it. $!";

  my $count = 0;
  while (my $line = <$fh>) {
    $count += sum_mult_operations($line);
  }

  close($fh);
  return $count;
}

sub sum_mult_operations {
  my ($text) = @_;
  my $total = 0;
  while ($text =~ /mul\((\d+),(\d+)\)/g) {
    $total += $1 * $2;
  }
  return $total;
}

main();
