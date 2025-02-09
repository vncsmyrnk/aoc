use strict;
use warnings;

sub main {
  my $count = process_file('input.txt');
  print "$count\n";
}

sub process_file {
  my ($file_name) = @_;
  my $concatenated_file_name = "/tmp/input-concatenated.txt";
  system("tr '\n' ' ' <$file_name >$concatenated_file_name");
  open(my $fh, '<', $concatenated_file_name) or die "Failed to read generated input file. $!";

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

  while ($text =~ /don't\(\)(.*?)do\(\)/g) {
    my $between = $1;

    while ($between =~ /mul\((\d+),(\d+)\)/g) {
      $total -= $1 * $2;
    }
  }

  return $total;
}

main();
