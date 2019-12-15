#!perl
use 5.010;
use strict;
use warnings;
use lib '../IntEmu/lib';

use IntEmu;

use Data::Dumper;

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
#$HW->{'debug'} = 1;
say "wait ",$HW->{'wait'};

# paddle first 18,22
my $paddle_x; # 0;
my $ball_x;
my $paddle_y; # 0;
my $ball_y   = 0;
my $move     = 0;


my $score = 0;

say "PHASE 2";

my $hit_paddel = 0;
my $itercount = 0;
my $wait;
my $paddle_hit;

while ( !$HW->{'halt'} || @{$HW->{'OUT'}}) {
#while ( !$HW->{'wait'} ) {
    $itercount++;

    my ($x,$y,$tid);

        #say "before ITER $itercount RUN $r IN [",join(',',@{$HW->{'IN'}}),"]";
        if ((@{$HW->{'OUT'}}) == 0) {
          #print "\n",' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";
          $HW->runit($code);
        }
        $x =   shift(@{$HW->{'OUT'}});
        $y =   shift(@{$HW->{'OUT'}});
        $tid = shift(@{$HW->{'OUT'}});

    #print ' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";

    #say "after ITER $itercount readout [",join(',',@readout),"]" if (($tid == 3) || ($tid == 4));

    if ($grid->[$x]->[$y] && ($tid == 0) && ($grid->[$x]->[$y] == 2)) {
      say "SHOT $x,$y after ITER $itercount";
    }

    if ($x == -1 && $y == 0) {
        $score = $tid;
        say "score $score";
    }
    else {
      $grid->[$x]->[$y] = $tid;
      if ($tid == 3) {
        if (!defined $paddle_x) {
          say "first PADD $x,$y at iter $itercount \n";
          #print ' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";
        }
        else { say "PADD [$x,$y] at iter $itercount"; }
        $paddle_x = $x;
        $paddle_y = $y;
      }
      elsif ($tid == 4) {
        #$HW->{'debug'} = 0;
        if (!defined $ball_x) {
          say "first BALL $x,$y at iter $itercount last move $move \n";
        }

        if (!defined $paddle_hit && defined $paddle_x) {
          if ($paddle_x == $x && ($paddle_y == $y+1)) {
            $paddle_hit++;
            say "PADD HIT ball [$x,$y] paddle [$paddle_x,$paddle_y] \n";
            #$move = 0;
            $move = $x - $ball_x;
            #$HW->{'debug'} = 1;
          }
        }
        elsif (defined $paddle_x) {
          ##my ($xp,$yp) = predict_collision($x,$ball_x,$y,$ball_x);
          my $xp = $x - $ball_x + $x;

          #if ($paddle_x < $x) {
          if ($paddle_x < $xp) {
            $move = 1;
          }
          #elsif ($paddle_x > $x) {
          elsif ($paddle_x > $xp) {
            $move = -1; # -1 .. left
          }
          else {
            $move = 0;
            #$move = $x - $ball_x;
          }

        }
        $ball_x = $x;
        $ball_y = $y;
        if (!defined $paddle_x) {
          say "BALL [$x,$y] at iter $itercount move $move";
        }
        else {
          say "BALL [$x,$y] at iter $itercount paddle [$paddle_x,$paddle_y] move $move";
        }
      }
    }
    #say "ball $ball_x,$ball_y paddle $paddle_x,$paddle_y move $move";
    if ($HW->{'wait'}) {
      if (!defined $wait) {
        say "first wait at iter $itercount last move $move \n";
        #print ' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";
        #say "ball $ball_x/$ball_y paddle $paddle_x/$paddle_y move $move";
        $wait++;
      }
      else {
        $wait++;
        #say "wait $wait at iter $itercount last move $move";
        if (defined $paddle_x) {
          #say "ball $ball_x/$ball_y paddle $paddle_x/$paddle_y move $move";
        }
      }
      push @{$HW->{'IN'}},$move;
      #$HW->{'IN'} = [$move];
      $HW->{'wait'} = 0;
    }

}

print_grid();

print "\n",' OUT: [',join(',',@{$HW->{'OUT'}}),"]\n";
say "ball $ball_x,$ball_y paddle $paddle_x,$paddle_y move $move";
say "iter $itercount";

say "score $score";

###### subs ######
sub predict_collision {
  my ($x1,$x0,$y1,$y0,$grid) = @_;

  my $xdir = ($x1 - $x0) + $x1; # +1 right, -1 left
  my $ydir = ($y1 - $y0) + $y1; # +1 down,  -1 up

  my $xmax = (scalar @{$grid})-1;
  my $ymax = (scalar @{$grid->[0]})-1;

  my $x2;
  my $y2;

  my $xt;
  my $yt;

  # $dir2dir->{$tile_id}{$x1delta}{$y1delta} = [$x2delta,$y2delta]
  # $x1delta : $x1 + $x1delta * $xdir; $xt = $x1 + $x1delta * $xdir;
  # $y1delta : $y1 + $y1delta * $ydir; $yt : $y1 + $y1delta * $ydir;
  my $dir2dir = {
    '0' => { '1' => { '1' => [+1,+1], }, }, # empty tile
    '1' => {
             '0' => { '1' => [-1,+1], },    # horizontal wall
             '1' => { '0' => [-1,+1], },    # vertical wall
    },
    '2' => { '1' => { '1' => [-1,-1], }, }, # block
    '3' => { '0' => { '1' => [+1,-1], }, }, # paddle
  };

  $xt = $x0 + 2 * $xdir;
  $yt = $y0 + 2 * $ydir;
  if ((defined $grid->[$xt][$yt])
       && ($xt >= 0) && ($xt <= $xmax) && ($yt >= 0) && ($yt <= $ymax) ) {
    if ($grid->[$x1 + 1 * $xdir][$y1 + 1 * $ydir] == 2) {
      my ($x2d,$y2d) = @{$dir2dir->{2}{1}{1}};
      $x2 = $x1 + $x2d * $xdir;
      $y2 = $x1 + $y2d * $ydir;
      }
    elsif ($grid->[$x1 + 0 * $xdir][$y1 + 1 * $ydir] == 3) {
      my ($x2d,$y2d) = @{$dir2dir->{2}{0}{1}};
      $x2 = $x1 + $x2d * $xdir;
      $y2 = $x1 + $y2d * $ydir;
    }
    elsif ($grid->[$x1 + 0 * $xdir][$y1 + 1 * $ydir] == 1) {
      my ($x2d,$y2d) = @{$dir2dir->{2}{0}{1}};
      $x2 = $x1 + $x2d * $xdir;
      $y2 = $x1 + $y2d * $ydir;
    }
    elsif ($grid->[$x1 + 1 * $xdir][$y1 + 0 * $ydir] == 1) {
      my ($x2d,$y2d) = @{$dir2dir->{2}{1}{0}};
      $x2 = $x1 + $x2d * $xdir;
      $y2 = $x1 + $y2d * $ydir;
    }
    else {
      $x2 = $x1 + 1 * $xdir;
      $y2 = $x1 + 1 * $ydir;
    }
  }
  else {say "ERROR no tile at [$xt,$yt] - should not happen";}

  return ($x2,$y2);

   # TODO: corners, block at wall (do not exist in example)
   # block id = 2

}

sub predict_collision_old {
  my ($x1,$x0,$y1,$y0,$grid) = @_;

  my $xdir = ($x1 - $x0) + $x1; # +1 right, -1 left
  my $ydir = ($y1 - $y0) + $y1; # +1 down,  -1 up

  my $xmax = (scalar @{$grid})-1;
  my $ymax = (scalar @{$grid->[0]})-1;

  my $x2;
  my $y2;

  my $xt;
  my $yt;
  #my $target_id;

  my $i=1;

  #$i<$xmax

  $xt = $x0 + 2 * $xdir;
  $yt = $y0 + 2 * $ydir;

  # last IX if (($xt < 0) || ($xt >= $xmax) || ($yt < 0) || ($yt >= $ymax));

   # TODO: corners, block at wall (do not exist in example)
   # block id = 2
   if ((defined $grid->[$xt][$yt])
       && ($xt >= 0) && ($xt <= $xmax) && ($yt >= 0) && ($yt <= $ymax) ) {

     if ($grid->[$xt][$yt] == 0) { # empty
       $x2 = $xt; # $x0 + 2*$xdir   $x1 +1*$xdir
       $y2 = $yt; # $y0 + 2*$ydir   $y1 +1*$ydir
     }
     elsif ($grid->[$xt][$yt] == 2) { # block
       $x2 = $x0; # $x1 -1*$xdir
       $y2 = $y0; # $y1 -1*$ydir
     }
     elsif ($grid->[$x0+1*$xdir][$y0 + 2*$ydir] == 3       # paddle
            || $grid->[$x0+1*$xdir][$y0 + 2*$ydir] == 1) { # horizontal wall
       $x2 = $xt; # $x0 + 2*$xdir $x1 +1*$xdir
       $y2 = $y0; #               $y1 -1*$ydir
     }
     elsif ($grid->[$x0+2*$xdir][$y0 + 1*$ydir] == 1) { # vertical wall
       $x2 = $x0; #              $x1 -1*$xdir
       $y2 = $yt; # $y0+2*$ydir; $y1 +1*$ydir
     }
     else {say "ERROR no prediction - should not happen";}
   }
   else {say "ERROR no tile at [$xt,$yt] - should not happen";}
   return ($x2,$y2);

}


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



