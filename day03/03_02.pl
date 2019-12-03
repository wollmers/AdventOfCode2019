#!perl

use strict;
use warnings;

my @input = <>;

my $string1 = $input[0];
my @wire1 = $string1 =~ m/([A-Z]\d+)/g;

my $string2 = $input[1];
my @wire2 = $string2 =~ m/([A-Z]\d+)/g;

my $points = {};

my $ops = {
  'U' => {'x' =>  0, 'y' =>  1},
  'R' => {'x' =>  1, 'y' =>  0},
  'D' => {'x' =>  0, 'y' => -1},
  'L' => {'x' => -1, 'y' =>  0},
};

my $x = 0;
my $y = 0;
my $steps = 0;

for my $part (@wire1) {
  my ($dir,$len) = $part =~ m/([A-Z])(\d+)/;

  for my $i (1..$len) {
      $steps++;
      $x += $ops->{$dir}{'x'};
      $y += $ops->{$dir}{'y'};
      if (!$points->{$x}{$y} ) { $points->{$x}{$y} = $steps; };
  }
}

my $crosses = [];
$x = 0;
$y = 0;
$steps = 0;
my $points2 = {};
for my $part (@wire2) {
  my ($dir,$len) = $part =~ m/([A-Z])(\d+)/;

  for my $i (1..$len) {
      $steps++;
      $x += $ops->{$dir}{'x'};
      $y += $ops->{$dir}{'y'};
      if (!$points2->{$x}{$y} ) { $points2->{$x}{$y} = $steps; };
      if ($points->{$x}{$y}) {
        push @$crosses,[$x,$y,$steps,$points->{$x}{$y}];
      }
  }
}

my $nearest = -1;
my $minsteps = -1;
for my $cross (@$crosses) {
  my ($x,$y,$steps1,$steps2) = @$cross;

  my $distance = abs($x) + abs($y);
  my $steps = $steps1 + $steps2;
  if ( $minsteps < 0 || $minsteps > $steps) {
    $minsteps = $steps;
  }
  if ( $nearest < 0 || $nearest > $distance) {
    $nearest = $distance;
  }
}

print 'value $nearest: ',$nearest,"\n";
print 'value $minsteps: ',$minsteps,"\n";

