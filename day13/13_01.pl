#!perl
use 5.010;
use strict;
use warnings;
use lib '../IntEmu/lib';

use IntEmu;

use Data::Dumper;

my $input = <>;

my $xmax = 0;
my $ymax = 0;
my $grid = [];

if (1) {

    my $HW   = IntEmu->new;

    my $code = $HW->{'code'};
    @{$code} = $input =~ m/([-]?\d+)/g;

    $HW->{'alloc_first'} = scalar @{$code};
    $HW->{'alloc_last'}  = $HW->{'alloc_first'};

    #push @{$HW->{'IN'}},$test->[0][0] if (@{$test->[0]});

    #$HW->{'debug'} = 1;
    $HW->{'wait'} = 1;

    my $actions = [];
    #my $out;
    #my $result = shift @{$HW->{'OUT'}};

    $HW->{'wait'} = 1;
    #$HW->{'debug'} = 1;
    $HW->runit($code);
    #$HW->decomp($code);

    say "OUT ",scalar @{$HW->{'OUT'}};

    for (1 .. int( scalar( @{$HW->{'OUT'}} )/3)) {
      my $x = shift @{$HW->{'OUT'}};
      my $y = shift @{$HW->{'OUT'}};
      my $tile_id = shift @{$HW->{'OUT'}};

      push @{$actions},[$x,$y,$tile_id];
    }

    my $tids = {
      '0' => 'empty',  # empty tile. No game object appears in this tile.
      '1' => 'wall',   # wall tile. Walls are indestructible barriers.
      '2' => 'block',  # block tile. Blocks can be broken by the ball.
      '3' => 'paddle', # horizontal paddle tile. The paddle is indestructible.
      '4' => 'ball',   # tile. The ball moves diagonally and bounces off objects.
    };

    my $pics = {
      '0' => ' ',   # empty tile. No game object appears in this tile.
      '1' => 'I',   # wall tile. Walls are indestructible barriers.
      '2' => 'x',   # block tile. Blocks can be broken by the ball.
      '3' => '=',   # horizontal paddle tile. The paddle is indestructible.
      '4' => 'O',   # tile. The ball moves diagonally and bounces off objects.
    };

    my $blocks = 0;

    my $action_count = 0;
    for my $action (@{$actions}) {
      $action_count++;

      my ($x,$y,$tid) = @{$action};

      #say "$action_count action $x,$y,$tids->{$tid}";

      if ($tid == 0) {
        $grid->[$x][$y] = $tid if (!exists $grid->[$x][$y]);
      }
      elsif ($tid == 1) {
        $grid->[$x][$y] = $tid;
      }
      elsif ($tid == 2) {
        $grid->[$x][$y] = $tid;
        $blocks++;
      }
      elsif ($tid == 3) {
        say "$action_count action $x,$y,$tids->{$tid}";
        $grid->[$x][$y] = $tid;
      }
      elsif ($tid == 4) {
        #$grid->[$x][$y] = $tid;
        say "$action_count action $x,$y,$tids->{$tid}";
        ball($x,$y);
      }
    }

    say " actions $action_count ";

    $xmax = (scalar @{$grid})-1;
    $ymax = (scalar @{$grid->[0]})-1;

    say "grid x $xmax y $ymax";
    say "blocks $blocks"; # 286

    print_grid();

}

sub ball{
  my ($x,$y) = @_;



}

sub print_grid {

    my $pics = {
      '0' => '_',   # empty tile. No game object appears in this tile.
      '1' => 'I',   # wall tile. Walls are indestructible barriers.
      '2' => 'x',   # block tile. Blocks can be broken by the ball.
      '3' => '=',   # horizontal paddle tile. The paddle is indestructible.
      '4' => 'O',   # tile. The ball moves diagonally and bounces off objects.
    };

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
      else { print '_'; }
    }
    print "\n";
  }

}



