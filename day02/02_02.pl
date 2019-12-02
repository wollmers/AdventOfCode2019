#!perl

use strict;
use warnings;

my $input = <>;
my @program;
my $target_result = 19690720;

# Each of the two input values will be between 0 and 99, inclusive.
for my $verb (0..99) {
  for my $noun (0..99) {
    @program = $input =~ m/(\d+)/g;
    if ($target_result == tryit($noun,$verb)) {
      my $answer = 100 * $noun + $verb;
      print '$answer: ',$answer,"\n";
    }
  }
}

sub tryit {
  my ($noun,$verb) = @_;
  $program[1] = $noun;
  $program[2] = $verb;

  for (my $i=0; $i < @program; $i += 4) {
    if ($program[$i + 0] == 99) { last; }
    elsif ($program[$i + 0] == 1) {
      $program[$program[$i + 3]]
        = $program[$program[$i + 1]] + $program[$program[$i + 2]];
    }
    elsif ($program[$i + 0] == 2) {
      $program[$program[$i + 3]]
        = $program[$program[$i + 1]] * $program[$program[$i + 2]];
    }
  }
  return $program[0];
}
