#!perl

use strict;
use warnings;

use Data::Dumper;

my $input = <>;




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

--- Part Two ---
The air conditioner comes online! Its cold air feels good for a while,
but then the TEST alarms start to go off.
Since the air conditioner can't vent its heat anywhere but back into the spacecraft,
it's actually making the air inside the ship warmer.

Instead, you'll need to use the TEST to extend the thermal radiators.
Fortunately, the diagnostic program (your puzzle input) is already equipped for this.
Unfortunately, your Intcode computer is not.

Your computer is only missing a few opcodes:

Opcode 5 is jump-if-true:
if the first parameter is non-zero,
  it sets the instruction pointer to the value from the second parameter.
  Otherwise, it does nothing.

Opcode 6 is jump-if-false:
  if the first parameter is zero,
    it sets the instruction pointer to the value from the second parameter.
  Otherwise, it does nothing.

Opcode 7 is less than:
  if the first parameter is less than the second parameter,
    it stores 1 in the position given by the third parameter.
  Otherwise, it stores 0.

Opcode 8 is equals:
  if the first parameter is equal to the second parameter,
    it stores 1 in the position given by the third parameter.
  Otherwise, it stores 0.

Like all instructions, these instructions need to support parameter modes as described above.

Normally, after an instruction is finished,
  the instruction pointer increases by the number of values in that instruction.
  However, if the instruction modifies the instruction pointer,
  that value is used and the instruction pointer is not automatically increased.

For example, here are several programs that take one input, compare it to the value 8, and then produce one output:

3,9,8,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
3,9,7,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
3,3,1108,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
3,3,1107,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).

Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:

3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 (using position mode)
3,3,1105,-1,9,1101,0,0,12,4,12,99,1 (using immediate mode)

Here's a larger example:

3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99

The above example program uses an input instruction to ask for a single number.
The program will then
  output 999 if the input value is below 8,
  output 1000 if the input value is equal to 8,
  or output 1001 if the input value is greater than 8.

This time, when the TEST diagnostic program runs its input instruction to get the ID of the system to test,
provide it 5, the ID for the ship's thermal radiator controller. This diagnostic test suite only outputs one number, the diagnostic code.

What is the diagnostic code for system ID 5?
=cut

#$input = '1002,4,3,4,33';


my $tests = [
[ 8,1,[3,9,8,9,10,9,4,9,99,-1,8],],
[ 7,0,[3,9,8,9,10,9,4,9,99,-1,8],],

[ 7,1,[3,9,7,9,10,9,4,9,99,-1,8],],
[ 8,0,[3,9,7,9,10,9,4,9,99,-1,8],],

[ 8,1,[3,3,1108,-1,8,3,4,3,99],],
[ 7,0,[3,3,1108,-1,8,3,4,3,99],],

[ 7,1,[3,3,1107,-1,8,3,4,3,99],],
[ 8,0,[3,3,1107,-1,8,3,4,3,99],],

[ 0,0,[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9],],
[ 8,1,[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9],],

[ 0,0,[3,3,1105,-1,9,1101,0,0,12,4,12,99,1],],
[ 8,1,[3,3,1105,-1,9,1101,0,0,12,4,12,99,1],],

[ 7,999,[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
  1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
  999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99],],
[ 8,1000,[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
  1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
  999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99],],
[ 9,1001,[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
  1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
  999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99],],

];

my $code = [];
my $IO = {'IN' => '', 'OUT' => '',};

if (1) {
my $test_count = 0;
my $test_limit = 999;
for my $test (@$tests) {
  $test_count++;
  last if ($test_count > $test_limit);
  $IO->{'IN'} = $test->[0];
  $IO->{'OUT'} = -999;
  @{$code} = @{$test->[2]};
  runit($IO,$code);
  if ($IO->{'OUT'} == $test->[1]) {
    print "$test_count OK \n";
  }
  else {
    print "$test_count FAIL expexted $test->[1] got $IO->{'OUT'} \n";
    print 'IN OUT ',"$IO->{'IN'} $IO->{'OUT'} \n";
    print '@{$code} ',join(' ',@{$code}),"\n";
  }
}
}

#exit;

if (1) {
$IO = {'IN' => '5', 'OUT' => '',};

@{$code} = $input =~ m/([-]?\d+)/g;
#print Dumper($code);
runit($IO,$code);

print $IO->{'OUT'},"\n"; # 11826654
}

sub runit {
  my ($IO,$code) = @_;

  for (my $i=0; $i < @{$code}; ) {
    my ($op,$p1,$p2,$p3) = op($code->[$i]);

    if ($op == 99) { last; }

    elsif ($op == 1) {
      $code->[$code->[$i + 3]]
        = val($code,$p1,$code->[$i + 1]) + val($code,$p2,$code->[$i + 2]);
      $i += 4;
    }
    elsif ($op == 2) {
      $code->[$code->[$i + 3]]
        = val($code,$p1,$code->[$i + 1]) * val($code,$p2,$code->[$i + 2]);
      $i += 4;
    }
    elsif ($op == 3) {
      $code->[$code->[$i + 1]]
        = $IO->{'IN'};
      $i += 2;
    }
    elsif ($op == 4) {
      $IO->{'OUT'} = val($code,$p1,$code->[$i + 1]);
      $i += 2;
    }
#Opcode 5 is jump-if-true:
#if the first parameter is non-zero,
#  it sets the instruction pointer to the value from the second parameter.
#  Otherwise, it does nothing.
    elsif ($op == 5) {
      if ( val($code,$p1,$code->[$i + 1]) != 0) {
        $i = val($code,$p2,$code->[$i + 2]);
        #print '$i $len val ',"$i $len _val($code,$p1,$code->[$i + 1])","\n";
      }
      else { $i += 3; }
    }

#Opcode 6 is jump-if-false:
#  if the first parameter is zero,
#    it sets the instruction pointer to the value from the second parameter.
#  Otherwise, it does nothing.
    elsif ($op == 6) {
      if ( val($code,$p1,$code->[$i + 1]) == 0) {
        $i = val($code,$p2,$code->[$i + 2]);
      }
      else { $i += 3; }
    }
#Opcode 7 is less than:
#  if the first parameter is less than the second parameter,
#    it stores 1 in the position given by the third parameter.
#  Otherwise, it stores 0.
    elsif ($op == 7) {
      if ( val($code,$p1,$code->[$i + 1])
          < val($code,$p2,$code->[$i + 2])) {
        $code->[$code->[$i + 3]] = 1;
      }
      else {
        $code->[$code->[$i + 3]] = 0;
      }
      $i += 4;
    }

#Opcode 8 is equals:
#  if the first parameter is equal to the second parameter,
#    it stores 1 in the position given by the third parameter.
#  Otherwise, it stores 0.
    elsif ($op == 8) {
      if ( val($code,$p1,$code->[$i + 1])
          == val($code,$p2,$code->[$i + 2])) {
        $code->[$code->[$i + 3]] = 1;
      }
      else {
        $code->[$code->[$i + 3]] = 0;
      }
      $i += 4;
    }
  }
}


=pod
ABCDE
 1002

DE - two-digit opcode,      02 == opcode 2
 C - mode of 1st parameter,  0 == position mode
 B - mode of 2nd parameter,  1 == immediate mode
 A - mode of 3rd parameter,  0 == position mode,
                                  omitted due to being a leading zero
=cut
sub op {
  my ($op) = @_;
  my ($instr) = $op =~ /(\d\d?)$/;
  $op =~ s/(\d\d?)$//;

  #print '$instr,$op: ',"$instr,$op","\n";

  $op = '000' . $op;

  my ($p3,$p2,$p1) = $op =~ /(\d)(\d)(\d)$/;

  return ($instr,$p1,$p2,$p3);
}
=pod
sub ops {
  my ($op) = @_;

  my $ops = {
    '1' => {'name' => 'ADD',  'arity' => 3, 'ins' => sub {$_[4] = $_[2] + $_[3];$_[0]+4} },
    '2' => {'name' => 'MULT', 'arity' => 3, 'ins' => sub {$_[4] = $_[2] * $_[3];$_[0]+4} },
    '3' => {'name' => 'IN',   'arity' => 1, 'ins' => sub {$_[2] = $_[1]->{'IN'};$_[0]+2} },
    '4' => {'name' => 'OUT',  'arity' => 1, 'ins' => sub {$_[1]->{'OUT'} = $_[2];$_[0]+2} },
    '5' => {'name' => 'JT',   'arity' => 2, 'ins' => sub {($_[2] != 0) ? $_[3] : $_[0]+3} },
    '6' => {'name' => 'JF',   'arity' => 2, 'ins' => sub {($_[2] == 0) ? $_[3] : $_[0]+3} },
    '7' => {'name' => 'STL',  'arity' => 3, 'ins' => sub {$_[4] = ($_[2]  < $_[3]) ? 1 : 0;$_[0]+4}} },
    '8' => {'name' => 'STE',  'arity' => 3, 'ins' => sub {$_[4] = ($_[2] == $_[3]) ? 1 : 0;$_[0]+4}} },

   '99' => {'name' => 'END',  'arity' => 0, 'ins' => sub { undef } },
  };

  return $ops->{$op};
}
=cut

sub val {
  my ($program,$p,$v) = @_;

  my $val = $p ? $v : $program->[$v];

  return $val;
}
