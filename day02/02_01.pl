#!perl

use strict;
use warnings;

my $input = <>;
my @program = $input =~ m/(\d+)/g;

$program[1] = 12;
$program[2] = 2;

for (my $i=0; $i < @program; $i += 4) {
  last if ($program[$i + 0] == 99);
  if ($program[$i + 0] == 1) {
    $program[$program[$i + 3]]
      = $program[$program[$i + 1]] + $program[$program[$i + 2]];
  }
  if ($program[$i + 0] == 2) {
    $program[$program[$i + 3]]
      = $program[$program[$i + 1]] * $program[$program[$i + 2]];
  }
}

print 'value at $program[0]: ',$program[0],"\n";
