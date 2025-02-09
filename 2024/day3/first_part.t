# vim: set ft=perl:

use strict;
use warnings;

use Test::More tests => 2;
require './first_part.pl';

subtest 'sum_mult_operations' => sub {
  my $result = sum_mult_operations('mul(2,4)asjodjmul[1,6);;;~çmul(12,5)kl');
  is($result, 68, 'sum_mult_operations should return correct sum for the test string');
};

subtest 'process_file' => sub {
  my $test_file_name = '/tmp/test_input.txt';
  open(my $fh, '>', $test_file_name) or die "Could not open file test file for writing: $!";
  print $fh "~çç~´mul(3,3)73tasgml(5,4)(1,3)mul[4,3)mul(4,1)llç\n";
  print $fh "sadjoasdjoadas210931230sjdoasjmul(1,3)asomulmul\n";
  close($fh) or die "Could not close test file: $!";

  my $result = process_file($test_file_name);
  is($result, 16, 'process_file should read the file and calculate the correct sum for all mul operations');
};

done_testing();
