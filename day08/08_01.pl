#!perl

use strict;
use warnings;

use Data::Dumper;


my $input = <>;my $width = 25;my $height = 6; # HZCZU

#my $input = '123456789789012012';my $width = 3;my $height = 3; # task 1: 1
#my $input = '0222112222120000';my $width = 2;my $height = 2; # task 2: 0110

my $layers = {};

my $ll = $width * $height;

if (1) {
  for (my $i=0; $i < length($input); $i += $ll) {
    my $string = substr($input,$i,$ll);

    my $layer = int($i / $ll);
    for my $integer (split(//,$string)) {
      $layers->{$layer}->{$integer}++;
    }
  }

  my $min_layer;
  my $min_zeros = 99999;
  for my $layer (keys %$layers) {
    if (exists $layers->{$layer}->{'0'} && ($layers->{$layer}->{'0'} < $min_zeros)) {
      $min_zeros = $layers->{$layer}->{'0'};
      $min_layer = $layer;
    }
  }
  my $result = $layers->{$min_layer}->{'1'} * $layers->{$min_layer}->{'2'};

  print '$min_zeros: ',$min_zeros,' layer: ',$min_layer,' result: ',$result,"\n";
}

# 0 is black,
# 1 is white, and
# 2 is transparent.


# if a given position has a transparent pixel in the first and second layers
# a black pixel in the third layer,
# and a white pixel in the fourth layer,
# => the final image would have a black pixel at that position.

$layers = {};
for (my $i=0; $i < length($input); $i += $ll) {
  my $string = substr($input,$i,$ll);

  my $layer = int($i / $ll);
  my $j = 0;
  for my $integer (split(//,$string)) {
    $layers->{$layer}->{$j} = $integer;
    $j++;
  }
}


my $image = {};

for (my $i=0;$i<$ll;$i++) {
  $image->{$i} = 2;
}

for (my $i=0;$i<$ll;$i++) {
  for my $layer (sort { $a <=> $b } keys %$layers) {
    if (($image->{$i} == 2)) {
      $image->{$i} = $layers->{$layer}->{$i};
    }
  }
}

my $result_string = '';

for my $i (sort { $a <=> $b } keys %$image) {
  $result_string .= $image->{$i};
}

print '$result_string: ',$result_string,"\n","\n";

for (my $i=0; $i < length($result_string); $i += $width) {
  my $string = substr($result_string,$i,$width);
  $string =~ s/0/ /g;
  $string =~ s/1/0/g;
  print $string,"\n";
}

# enlarge gaps between glyphs
my $h_gaps = [];

for (my $j=0;$j < $width; $j++) {
  $h_gaps->[$j] = 0;
}

for (my $i=0; $i < length($result_string); $i += $width) {
  my $string = substr($result_string,$i,$width);
  my $array = [split(//,$string)];
  for (my $j=0;$j < length($string); $j++) {
    if ($h_gaps->[$j] ne $array->[$j]) { $h_gaps->[$j] = 1; }
  }
}

print "\n","\n",'$h_gaps: ',@{$h_gaps},"\n","\n";

for (my $i=0; $i < length($result_string); $i += $width) {
  my $string = substr($result_string,$i,$width);
  my $array = [split(//,$string)];
  my $line = '';
  for (my $j=0;$j < length($string); $j++) {
    if ($h_gaps->[$j] eq '0') { $line .= '00'; }
    else { $line .= $array->[$j]; }
  }
  $line =~ s/0/ /g;
  $line =~ s/1/0/g;
  print $line,"\n";
}
print "\n";
