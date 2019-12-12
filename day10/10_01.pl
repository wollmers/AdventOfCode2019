#!perl
use 5.010;
use strict;
use warnings;


use Data::Dumper;



my $s1 =<<EOF;
.#..#
.....
#####
....#
...##
EOF

# Best is 5,8 with 33 other asteroids detected:
my $s2 =<<EOF;
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
EOF

# Best is 1,2 with 35 other asteroids detected:

my $s3 =<<EOF;
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
EOF

#my @lines = split(/\n/,$s3);
my @lines = <>;

my $y=0;
my $x=0;

my $map = {};
for my $line (@lines) {
  #say "$y $line";
  $x = 0;
  for my $char (split(//,$line)) {
    if ($char eq '#') {
      $map->{$x}{$y} = $char;
    }
    $x++;
  }
  $y++;
}

my $width = $x;
my $height = $y;

say "$x,$y";
#print Dumper($map);

my $seen = {};
my $beams = {};
my $see = {};

for ($y=0;$y<$height;$y++) {
  for ($x=0;$x<$width;$x++) {
    if (($x == $y) && $x && $y) {
      $beams->{1}->{1} = 1;
      next;
    }
    elsif ( ($x == 0) ) {
      $beams->{0}->{1} = 1;
      next;
    }
    elsif ( ($y == 0) ) {
      $beams->{1}->{0} = 1;
      next;
    }
    else {
        my $dmax = ($x > $y) ? $x : $y;
        my $div_min = 1;
        my $xmin = $x;
        my $ymin = $y;
        #say "start $x $y $dmax";
        for (my $div=$dmax;$div>1;$div--) {
          if ( ($xmin % $div) || ($ymin % $div) ) { next; }
          $div_min *= $div;
          $xmin /= $div;
          $ymin /= $div;
          #say " / $div => $xmin $ymin";
        }
        #say "-> $div_min";
        #if (!(($x % $div_min) || ($y % $div_min))) {
          #my $xb = (($x % $div_min) || ($y % $div_min)) ? $x : ($x / $div_min);
          #my $yb = (($x % $div_min) || ($y % $div_min)) ? $y : ($y / $div_min);
          my $xb = $xmin;
          my $yb = $ymin;
          $beams->{$xb}{$yb} = 1;
          #say "$x $y => beams $xb $yb = $div_min";
        #}

    }
  }
}

if (1) {
for ($x=0;$x<$width;$x++) {
  for ($y=0;$y<$height;$y++) {
    if (exists $map->{$x}{$y}) {
      #say " see $x $y";
      see($x,$y,$width,$height,$map);
    }
  }
}
}

#see(5,2,$width,$height,$map);

sub see {
  my ($x,$y,$width,$height,$map) = @_;

  $seen = {};

  my $max = ($width > $height) ? $width : $height;

  for my $xb (keys %{$beams}) {
    for my $yb (keys %{$beams->{$xb}}) {
      for my $fx (-1,1) {
        for my $fy (-1,1) {
          for my $f (1 .. $max) {
            my $yt = ($yb * $fy * $f) + $y;
            my $xt = ($xb * $fx * $f) + $x;
            my $xbf = $xb * $fx;
            my $ybf = $yb * $fy;
            if (($xt == $x) && ($yt == $y)) {next }
            elsif ( ($yt < 0)  || ($yt >= $height) ) {next }
            elsif ( ($xt < 0)  || ($xt >= $width) ) {next }
            elsif ( (!(exists $seen->{$xbf}->{$ybf} )) && (exists $map->{$xt}{$yt}) ) {
                #say "new seen $xbf $ybf => $xt $yt";
                $seen->{$xbf}->{$ybf}++;
                $see->{$x}{$y}++;
            }
            #else {say "not new seen $xb $yb => $xt $yt";}

          }
        }
      }
    }
  }
}

#print Dumper($map);
#print Dumper($beams);
#print Dumper($seen);
#print Dumper($see);

my $x_max   = 0;
my $y_max   = 0;
my $see_max = 0;

for my $x (keys %{$see}) {
  for my $y (keys %{$see->{$x}}) {
    if ($see_max < $see->{$x}{$y}) {
      $x_max   = $x;
      $y_max   = $y;
      $see_max = $see->{$x}{$y};
    }
  }
}

say " result ($x_max,$y_max) => $see_max "; # result (26,29) => 303
