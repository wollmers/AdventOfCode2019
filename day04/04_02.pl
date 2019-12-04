#!perl

use strict;
use warnings;

use Data::Dumper;

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

--- Part Two ---
An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

Given this additional criterion, but still ignoring the range rule, the following are now true:

112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).
How many different passwords within the range given in your puzzle input meet all of the criteria?

Your puzzle input is still 171309-643603.

=cut

my $low = 171309;
my $high = 643603;

my ($count1,$count2) = (0,0);

PWD: for my $i ($low..$high) {
#PWD: for my $i (171309..643603) {
#PWD: for my $i (111122..111122) {
  my @digits = $i =~ /(\d)/g;
  my $last = '';
  my $doubles = 0;
  my $groups = {};

  DIGIT: for my $digit (@digits) {
    $groups->{$digit}++;
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
  if ($doubles) {
    my $has_double = 0;
    for my $digit (keys %$groups) {
      if ($groups->{$digit} == 2) {$has_double++}
    }
    $count1++ if $has_double;
  }
}


print 'value $count1: ',$count1,"\n";

# solution using sort, map

($count1,$count2) = (0,0);

PWD: for my $i ($low..$high) {

  my @digits = $i =~ /(\d)/g;
  if ($i ne join('',sort @digits)) { next PWD }

  my $groups = {};
  map { $groups->{$_}++ } @digits;
  for my $digit (@digits) {
    #if ($groups->{$digit} && $groups->{$digit} >= 2) { # part 1
    #  $count1++;
    #  next PWD;
    #}
    if ($groups->{$digit} && $groups->{$digit} == 2) { # part 2
      $count2++;
      next PWD;
    }
  }
}
print '$count2: ',"$count2","\n";

# solution using regex

($count1,$count2) = (0,0);

for my $i ($low..$high) {

  if ($i =~ /^0*1*2*3*4*5*6*7*8*9*$/) {
    my @reps = $i =~ /(.)\1+/g;
    my $groups = {};
    map { $groups->{$_}++ } split(//,$i);

    #if (@reps >= 1) {$count1++;}
    if (@reps) {$count1++;}
    #if (grep {$_ >= 2} values %$groups) {$count1++;}
    if (grep {$_ == 2} values %$groups) {$count2++;}
  }
}
print '$count1 $count2: ',"$count1 $count2","\n";

# solution using map/grep

($count1,$count2) = (0,0);

for my $i ($low..$high) {

  my $groups = {};
  map { $groups->{$_}++ } split(//,$i);

  if ((keys %$groups) < length($i)) {
    if (grep {$_ >= 2} values %$groups) {$count1++;}
    if (grep {$_ == 2} values %$groups) {$count2++;}
  }
}
print '$count1 $count2: ',"$count1 $count2","\n";
