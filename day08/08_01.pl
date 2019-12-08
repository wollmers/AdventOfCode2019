#!perl
use strict;
use warnings;

my $input = <>;my $width = 25;my $height = 6; # 2016
#my $input = '123456789789012012';my $width = 3;my $height = 3; # 1

my $ll = $width * $height;

my $layers = {};
for (my $i=0; $i < length($input); $i += $ll) {
    my $string = substr($input,$i,$ll);

    my $layer = int($i / $ll);
    for my $integer (split(//,$string)) {
      $layers->{$layer}->{$integer}++;
    }
}

my $min_layer;
my $min_zeros = 99999999;
for my $layer (keys %$layers) {
    if (exists $layers->{$layer}->{'0'} && ($layers->{$layer}->{'0'} < $min_zeros)) {
      $min_zeros = $layers->{$layer}->{'0'};
      $min_layer = $layer;
    }
}

print 'result: ',$layers->{$min_layer}->{'1'} * $layers->{$min_layer}->{'2'},"\n";
