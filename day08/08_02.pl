#!perl
use strict;
use warnings;

my $input = <>;my $width = 25;my $height = 6; # HZCZU

my $ll = $width * $height;

my $layers = {};
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
for (my $i=0;$i<$ll;$i++) { $image->{$i} = 2; } # 2 is transparent

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

for (my $i=0; $i < length($result_string); $i += $width) {
  my $string = substr($result_string,$i,$width);
  $string =~ s/0/  /g;
  $string =~ s/1/##/g;
  print $string,"\n";
}
