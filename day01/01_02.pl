#!perl

use strict;
use warnings;

my @modules = <>;

my $fuel_counter = 0;
my $additional_fuel = 0;

for my $module (@modules) {
    my $mass = $module;
    my $fuel = int($mass / 3) - 2;
    $fuel_counter += $fuel;
    $additional_fuel += additional_fuel($fuel);
}

print '$fuel_counter: ',$fuel_counter,"\n";

sub additional_fuel {
  my $mass = shift;

  my $fuel = int($mass / 3) - 2;
  if ($fuel <= 0) { return 0; }
  return $fuel + additional_fuel($fuel);
}

print '$additional_fuel: ',$additional_fuel,"\n";

my $total_fuel = $fuel_counter + $additional_fuel;

print '$total_fuel: ',$total_fuel,"\n";
