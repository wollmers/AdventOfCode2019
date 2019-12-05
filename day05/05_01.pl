#!perl

use strict;
use warnings;

my $input = <>;
my @program;

my $in = 1;
my $out;

=pod

First, you'll need to add two new instructions:

Opcode 3 takes a single integer as input and saves it to the address given by its only parameter.
  For example, the instruction 3,50 would take an input value and store it at address 50.

Opcode 4 outputs the value of its only parameter. For example, the instruction 4,50 would output the value at address 50.

Programs that use these instructions will come with documentation that explains what should be connected to the input and output.

The program 3,0,4,0,99 outputs whatever it gets as input, then halts.

Second, you'll need to add support for parameter modes:

Each parameter of an instruction is handled based on its parameter mode.
Right now, your ship computer already understands parameter mode 0, position mode,
which causes the parameter to be interpreted as a position - if the parameter is 50,
its value is the value stored at address 50 in memory. Until now, all parameters have been in position mode.

Now, your ship computer will also need to handle parameters in mode 1, immediate mode.
In immediate mode, a parameter is interpreted as a value - if the parameter is 50, its value is simply 50.

ABCDE
 1002

DE - two-digit opcode,      02 == opcode 2
 C - mode of 1st parameter,  0 == position mode
 B - mode of 2nd parameter,  1 == immediate mode
 A - mode of 3rd parameter,  0 == position mode,
                                  omitted due to being a leading zero
Examples:
1101,100,-1,4,0
1002,4,3,4,33


result: 7259358
=cut

#$input = '1002,4,3,4,33';

@program = $input =~ m/([-]?\d+)/g;

#print '@program: ',join(' ',@program),"\n";

runit();

print $out,"\n";

sub runit {
  #my ($noun,$verb) = @_;
  #$program[1] = $noun;
  #$program[2] = $verb;

  my $len = 0;
  for (my $i=0; $i < @program; $i += $len) {
    my $opcode = $program[$i + 0];
    #print '$i,$opcode: ',"$i,$opcode","\n";
    my ($op,$p1,$p2,$p3) = op($opcode);

    #print '$op,$p1,$p2,$p3: ',"$op,$p1,$p2,$p3","\n";

    if ($op == 99) { last; }

    elsif ($op == 1) {
      $program[$program[$i + 3]]
        = _val(\@program,$p1,$program[$i + 1]) + _val(\@program,$p2,$program[$i + 2]);
        #= $program[$program[$i + 1]] + $program[$program[$i + 2]];
      $len = 4;
    }
    elsif ($op == 2) {
      $program[$program[$i + 3]]
        = _val(\@program,$p1,$program[$i + 1]) * _val(\@program,$p2,$program[$i + 2]);
        #= $program[$program[$i + 1]] * $program[$program[$i + 2]];
      $len = 4;
    }
    elsif ($op == 3) {
      $program[$program[$i + 1]]
        = $in;
      $len = 2;
    }
    elsif ($op == 4) {
      $out = _val(\@program,$p1,$program[$i + 1]);
      $len = 2;
    }
  }
}

sub op {
  my ($op) = @_;
  my ($instr) = $op =~ /(\d\d?)$/;
  $op =~ s/(\d\d?)$//;

  #print '$instr,$op: ',"$instr,$op","\n";

  $op = '000' . $op;
  my @parms = $op =~ /(\d)/g;
  @parms = reverse @parms;

  my ($p1,$p2,$p3) = @parms;

  return ($instr,$p1,$p2,$p3);
}

sub _val {
  my ($program,$p,$v) = @_;

  my $val = $p ? $v : $program->[$v];

  #print '$p,$v,$val: ',"$p,$v,$val","\n";
  return $val;
}
