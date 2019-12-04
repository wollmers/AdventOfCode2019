#!perl

use strict;
use warnings;

=pod

However, they do remember a few key facts about the password:

It is a six-digit number.
The value is within the range given in your puzzle input.
Two adjacent digits are the same (like 22 in 122345).
Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
Other than the range rule, the following are true:

111111 meets these criteria (double 11, never decreases).
223450 does not meet these criteria (decreasing pair of digits 50).
123789 does not meet these criteria (no double).
How many different passwords within the range given in your puzzle input meet these criteria?

Your puzzle input is 171309-643603.

=cut

my $low = 171309;
my $high = 643603;

my $count = 0;

PWD: for my $i (171309..643603) {
  my @digits = $i =~ /(\d)/g;
  my $last = '';
  my $doubles = 0;

  DIGIT: for my $digit (@digits) {
    if (!$last) {
      $last =  $digit;
      next DIGIT;
    }
    if ($last == $digit) {
      $doubles++;
    }
    if ($digit >= $last) {
      $last =  $digit;
    }
    else {next PWD}
  }
  if ($doubles) {$count++}

}


print 'value $count: ',$count,"\n";


