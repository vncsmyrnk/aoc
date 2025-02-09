# vim: set ft=perl:

use strict;
use warnings;

use Test::More tests => 2;
require './second_part.pl';

subtest 'sum_mult_operations' => sub {
  my $result = sum_mult_operations('291h0dsasdmul(4,7);.;,~asdmmul(8,2)aksodk1don\'t()asjo1230jsmul(4,12)ssa=dkmul(2,1)pasdk120do()aosdjo=-123mul(7,5)');
  is($result, 79, 'sum_mult_operations should return correct sum for the test string');
};

subtest 'process_file' => sub {
  my $test_file_name = '/tmp/test_input.txt';
  open(my $fh, '>', $test_file_name) or die "Could not open file test file for writing: $!";
  print $fh "021h9hsidmul(12,3)´[]*asdjdon't()h012mul(3,5)oasdj12mul(4512)asodhd\n";
  print $fh "j=230mul(4,6)0-414u0asolj3mul(2,7)as0j123=do()0oj123mul(4,2)=as213=\n";
  close($fh) or die "Could not close test file: $!";

  my $result = process_file($test_file_name);
  is($result, 44, 'process_file should read the file and calculate the correct sum for all mul operations');
};

done_testing();
