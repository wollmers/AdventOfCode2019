#!perl
use 5.010;
use strict;
use warnings;

#use Math::Vec;
use Math::Trig qw( atan :pi);
use Data::Dumper;

# Best at 3,4 because it can detect 8
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

# Best is 11,13 with 210 other asteroids detected:
# The 200th asteroid to be vaporized is at 8,2.
my $s4 =<<EOF;
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
EOF

#my @lines = split(/\n/,$s4);
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

my $see = {};
my $clock = [];

if (1) {
for (my $x=0;$x<$width;$x++) {
  for (my $y=0;$y<$height;$y++) {
    if (exists $map->{$x}{$y}) {
      see($x,$y,$width,$height,$map);
    }
  }
}
}

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

say "result task1 ($x_max,$y_max) => $see_max "; # result (26,29) => 303

my $vaporized = 0;
my ($last_x,$last_y) = vaporize($x_max,$y_max,$width,$height,$map);

say "$vaporized last [$last_x, $last_y] result task 2 ",
    "[$last_x, $last_y]"," => ",$last_x*100+$last_y,
    " at $vaporized"; # 200 last [4, 8] result task 2 408

sub clock {
  my ($x0,$y0,$width,$height) = @_;
  #say "clock at $x0 $y0";
  my $pos = {};
  my $neg = {};
  $clock  = [];
  for (my $x=0;$x<$width;$x++) {
    for (my $y=0;$y<$height;$y++) {
      if ( $x0 == $x && $y0 == $y ) { next }
      unless (exists $map->{$x}{$y}) { next }

	  my $xrel = $x - $x0;
      my $yrel = ($height-1-$y) - ($height-1-$y0); # y0 = bottom
      my $rad = sprintf("%.10f",atan2($xrel,$yrel));
      my $len = sprintf("%.10f",sqrt($xrel**2 + $yrel**2));
      if ($rad >= 0) {
        $pos->{$rad}->{$len} = [$x,$y];
      }
      else {
        $neg->{$rad}->{$len} = [$x,$y];
      }
    }
  }
  # turn clock to 0
  for my $degs ($pos,$neg) {
    for my $rad (sort { $a <=> $b  } keys %{$degs}) {
      for my $len (sort { $a <=> $b  } keys %{$degs->{$rad}}) {
        my ($x,$y) = @{$degs->{$rad}->{$len}};
        push @{$clock},[$rad,$len,$x,$y];
      }
    }
  }
}

sub see {
  my ($x,$y,$width,$height,$map) = @_;

  my $seen = {};

  clock($x,$y,$width,$height);

  my $last_angle = -999;

  ANGLE: for my $item (@{$clock}) {
      my ($angle,$len,$xt,$yt) = @{$item};

      if ( (!(exists $seen->{$xt}->{$yt} )) && (exists $map->{$xt}{$yt}) ) {
          if ($angle == $last_angle) { next ANGLE }
          $last_angle = $angle;
          $seen->{$xt}->{$yt}++;
          $see->{$x}{$y}++;
      }
   }
}

sub vaporize {
  my ($x,$y,$width,$height,$map) = @_;

  clock($x,$y,$width,$height);

  while (($vaporized < 200)) {
    my $last_angle = -999;

    ANGLE: for my $item (@{$clock}) {
      my ($angle,$len,$xt,$yt) = @{$item};
      if ( (exists $map->{$xt}{$yt}) ) {
        if ($angle == $last_angle) { next ANGLE }
        $last_angle = $angle;
        delete $map->{$xt}{$yt};
        $vaporized++;

        if ($vaporized >= 200) { return ($xt,$yt); }
      }
    }
  }
}

sub print_clock {
  my ($clock) = @_;
  say "print_clock";

  for my $item (@{$clock}) {
      say join(' ', @{$item} );
  }
}

sub atan2 {
  my ($x,$y) = @_;

  my $rad;
  if    ($x > 0)             { $rad = atan($y/$x) }
  elsif ($x <  0 && $y >  0) { $rad = atan($y/$x) + pi }
  elsif ($x <  0 && $y == 0) { $rad = - pi }
  elsif ($x <  0 && $y <  0) { $rad = atan($y/$x) - pi }
  elsif ($x == 0 && $y >  0) { $rad = pi/2 }
  elsif ($x == 0 && $y <  0) { $rad = -1 * pi/2 }

  return $rad;
}

