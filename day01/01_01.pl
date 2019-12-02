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
}

print '$fuel_counter: ',$fuel_counter,"\n";
