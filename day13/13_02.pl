#!perl
use 5.010;
use strict;
use warnings;

use lib '../IntEmu/lib';
use IntEmu;


my $input = <>;

my $HW   = IntEmu->new;

my $code = $HW->{'code'};
@{$code} = $input =~ m/([-]?\d+)/g;

$HW->{'alloc_first'} = scalar @{$code};
$HW->{'alloc_last'}  = $HW->{'alloc_first'};
$HW->alloc($code,10000);

# The game didn't run because you didn't put in any quarters.
# Unfortunately, you did not bring any quarters.
# Memory address 0 represents the number of quarters
# that have been inserted; set it to 2 to play for free.

$HW->{'code'}->[0] = 2;

my $grid = [];


# paddle first 18,22
my $paddle_x = 0; # 0;
my $ball_x   = 0;

my $move     = 0;
my $score    = 0;

my $hit_paddel = 0;
my $itercount = 0;
my $wait = 0;
my $paddle_hit = 0;

while ( !$HW->{'halt'} || @{$HW->{'OUT'}} ) {

    $itercount++;

    if ((@{$HW->{'OUT'}}) == 0) {
          $HW->runit($code);
    }
    my $x   = shift(@{$HW->{'OUT'}});
    my $y   = shift(@{$HW->{'OUT'}});
    my $tid = shift(@{$HW->{'OUT'}});


    if ($x == -1 && $y == 0) {
        $score = $tid;
        #say "score $score";
    }
    else {
        $grid->[$x]->[$y] = $tid;

        if ($tid == 3) { $paddle_x = $x; }
        elsif ($tid == 4) {
            if    ($paddle_x < $x) { $move =  1; }
            elsif ($paddle_x > $x) { $move = -1; }
            else  { $move = 0; }

            $ball_x = $x;
        }
    }

    $HW->{'IN'}   = [$move];
    $HW->{'wait'} = 0;

}


#print_grid();

#print "\n",' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";
say "iter $itercount";

say "score $score";

# iter 26313
# score 14538

###### subs ######

sub print_grid {

    my $pics = {
      '0' => ' ',   # empty  tile. No game object appears in this tile.
      '1' => 'I',   # wall   tile. Walls are indestructible barriers.
      '2' => 'x',   # block  tile. Blocks can be broken by the ball.
      '3' => '=',   # paddle tile. The paddle is indestructible.
      '4' => 'O',   # ball   moves diagonally and bounces off objects.
    };

    my $xmax = (scalar @{$grid})-1;
    my $ymax = (scalar @{$grid->[0]})-1;

    say "grid x $xmax y $ymax";

    print '   ';
    for my $x (0 .. $xmax) {
      my $c = ( $x % 10) ? ' ' : int($x/10);
      print $c;
    }
    print "\n";
    print '   ';
    for my $x (0 .. $xmax) { print int($x%10) ; }
    print "\n";

    for my $y (0 .. $ymax) {
      print sprintf("%2s",$y),' ';
      for my $x (0 .. $xmax) {
        if ($grid->[$x][$y]) {
          print $pics->{$grid->[$x][$y]};
        }
        else { print $pics->{0}; }
      }
      print "\n";
    }
}



