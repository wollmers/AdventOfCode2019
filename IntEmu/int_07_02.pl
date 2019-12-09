#!perl
use strict;
use warnings;

use Data::Dumper;

#my $input = <>;


my $tests = [
#  p1 p2        0    1   2   3  4   5   6   7  8  9
[ [0, 0], 0,[1101,   0,  0,  9, 4,  9, 99,  0, 0, 9],'ADD lit 1'],
[ [1, 2], 3,[1101,   1,  2,  9, 4,  9, 99,  0, 0, 9],'ADD lit 2'],
[ [1,-2],-1,[1101,   1, -2,  9, 4,  9, 99,  0, 0, 9],'ADD lit 3'],

[ [0, 0], 0,[   1,   7,  8,  9, 4,  9, 99,  0, 0, 9],'ADD adr 1'],
[ [1, 2], 3,[   1,   7,  8,  9, 4,  9, 99,  1, 2, 9],'ADD adr 2'],
[ [1,-2],-1,[   1,   7,  8,  9, 4,  9, 99,  1,-2, 9],'ADD adr 3'],

[ [0, 0], 0,[1102,   0,  0,  9, 4,  9, 99,  0, 0, 9],'MULT lit 1'],
[ [1, 2], 2,[1102,   1,  2,  9, 4,  9, 99,  0, 0, 9],'MULT lit 2'],
[ [1,-2],-2,[1102,   1, -2,  9, 4,  9, 99,  0, 0, 9],'MULT lit 3'],

[ [0, 0], 0,[   2,   7,  8,  9, 4,  9, 99,  0, 0, 9],'MULT adr 1'],
[ [1, 2], 2,[   2,   7,  8,  9, 4,  9, 99,  1, 2, 9],'MULT adr 2'],
[ [1,-2],-2,[   2,   7,  8,  9, 4,  9, 99,  1,-2, 9],'MULT adr 3'],

#  p1 p2        0    1   2   3  4   5   6   7  8  9  10 11 12
[ [1,-2], 1,[   3,   7,  4,  7, 99, 1, -2,  9],'IN adr 1'],

[ [1,-2], 1,[ 104,   1, 99,  1,-2, 9],'OUT lit 1'],
[ [1,-2], 1,[   4,   3, 99,  1,-2, 9],'OUT adr 2'],

#  p1 p2         0    1   2   3   4   5    6  7   8   9  10 11 12
[ [1,-2], 1,[ 1105,   1,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JT lit 1'],
[ [1,-2], 0,[ 1105,   0,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JT lit 2'],

[ [1,-2], 1,[    5,   9, 10, 104, 0, 99, 104, 1, 99,  1,  6, 9],'JT adr 1'],
[ [1,-2], 0,[    5,   9, 10, 104, 0, 99, 104, 1, 99,  0,  6, 9],'JT adr 2'],

#  p1 p2         0    1   2   3   4   5    6  7   8   9  10 11 12
[ [1,-2], 1,[ 1106,   0,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JF lit 1'],
[ [1,-2], 0,[ 1106,   1,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JF lit 2'],

[ [1,-2], 1,[    6,   9, 10, 104, 0, 99, 104, 1, 99,  0,  6, 9],'JF adr 1'],
[ [1,-2], 0,[    6,   9, 10, 104, 0, 99, 104, 1, 99,  1,  6, 9],'JF adr 2'],

#  p1 p2         0    1   2   3    4   5    6    7   8   9  10 11 12
[ [1,-2], 1,[ 1107,   0,  6,  7,   4,  7,  99,   0, -2, 9],'STL lit 1'],
[ [1,-2], 0,[ 1107,   6,  0,  7,   4,  7,  99,   1, -2, 9],'STL lit 2'],

[ [1,-2], 1,[    7,   7,  8,  9,   4,  9,  99,   0,  6, 9],'STL adr 1'],
[ [1,-2], 0,[    7,   7,  8,  9,   4,  9,  99,   6,  0, 9],'STL adr 2'],

# STE
#  p1 p2         0    1   2   3    4   5    6    7   8   9  10 11 12
[ [1,-2], 1,[ 1108,   6,  6,  7,   4,  7,  99,   0, -2, 9],'STE lit 1'],
[ [1,-2], 0,[ 1108,   6,  7,  7,   4,  7,  99,   1, -2, 9],'STE lit 2'],

[ [1,-2], 1,[    8,   7,  8,  9,   4,  9,  99,   6,  6, 9],'STE adr 1'],
[ [1,-2], 0,[    8,   7,  8,  9,   4,  9,  99,   6,  7, 9],'STE adr 2'],

];

my $code = [];
my $HW_init = {
  'IN'    => '',
  'OUT'   => '',
  'i'     => 0,
  'p1'    => 0,
  'p2'    => 0,
  'p3'    => 0,
  'debug' => 0,
  'halt'  => 0,
  'wait'  => 0,
};

if (1) {
  my $test_count = 0;
  my $test_skip  = 0;
  my $test_limit = 999;

  for my $test (@$tests) {
    $test_count++;
    next if ($test_count <= $test_skip);
    last if ($test_count > $test_limit);

    my $code = [];
    @{$code} = @{$test->[2]};

    my $HW   = {};
    %{$HW}   = %{$HW_init};

    $HW->{'IN'} = $test->[0][0];

    runit($HW,$code);

    my $result = $HW->{'OUT'};

    if ($result == $test->[1]) {
      print "$test_count OK - ",$test->[3],"\n";
    }
    else {
      print "$test_count FAIL expected ",$test->[1]," got $result - ",$test->[3],"\n";
    }
  }
}

if (0) {
  my $test_count = 0;
  my $test_skip  = 0;
  my $test_limit = 99;

  for my $test (@$tests) {
    $test_count++;
    next if ($test_count <= $test_skip);
    last if ($test_count > $test_limit);

    my $code = [];
    @{$code} = @{$test->[2]};

    my $HW   = {};
    %{$HW}   = %{$HW_init};

    print "$test_count decompile - ",$test->[3],"\n";
    print '$code: ',code_array2string($code),"\n";
    decomp($HW,$code);
  }
}

###### SUBS ##########

sub runit {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',' IN: ',$HW->{'IN'},"\n";
    print 'ADDR',"\n";
  }

  for ( ; $HW->{'i'} < @{$code}; ) {

    my $op = op($HW,$code);
    if ($HW->{'debug'} > 0) { print_line($HW,$code); }
    if ($op == 99) { $HW->{'halt'} = 1; return; }
    elsif ($op == 3) {
      if ($HW->{'wait'}) { return; }
      ops($op)->{'ins'}->($HW,$code);
      $HW->{'wait'} = 1;
    }
    else {
      ops($op)->{'ins'}->($HW,$code);
    }
  }
}

sub step {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',' IN: ',$HW->{'IN'},"\n";
    print 'ADDR',"\n";
  }

  my $op = op($HW,$code);

  if ($HW->{'debug'} > 0) { print_line($HW,$code); }

  ops($op)->{'ins'}->($HW,$code);
}

=pod
ABCDE
 1002

DE - two-digit opcode,      02 == opcode 2
 C - mode of 1st parameter,  0 == position mode
 B - mode of 2nd parameter,  1 == immediate mode
 A - mode of 3rd parameter,  0 == position mode, omit leading zero
=cut

sub op {
  my ($HW,$code) = @_;

  my $op = $code->[$HW->{'i'}];

  my ($instr) = $op =~ /(\d?\d)$/;

  $op =~ s/(\d?\d)$//;

  $op = '000' . $op;

  ($HW->{'p3'},$HW->{'p2'},$HW->{'p1'}) = $op =~ /(\d)(\d)(\d)$/;

  $instr =~ s/^0*//;

  return $instr;
}

sub v {
  my ($HW,$code,$p) = @_;

  my $px = 'p' . $p;

  # immediate (literal) mode set ? litteral : value at address
  my $val = $HW->{$px} ? $code->[$HW->{'i'} + $p] : $code->[$code->[$HW->{'i'} + $p]];

  return $val;
}

sub f {
  my ($HW,$code,$p) = @_;

  my $px = 'p' . $p;

  # immediate (literal) mode set ? literal : value at address
  my $val = $HW->{$px} ? $code->[$HW->{'i'} + $p] : '*' . $code->[$HW->{'i'} + $p];

  return $val;
}

sub ops {
  my ($op) = @_;

  my $ops = {
    '1' => {
      'name' => 'ADD',
      'arity' => 3,
      'ins' => sub {
        my ($HW,$code) = @_;
        $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) + v($HW,$code,2);
        $HW->{'i'} += 4;
      },
    },
    '2' => {
      'name' => 'MULT',
      'arity' => 3,
      'ins' => sub {
        my ($HW,$code) = @_;
        $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) * v($HW,$code,2);
        $HW->{'i'} += 4;
      }
    },
    '3' => {
      'name' => 'IN',
      'arity' => 1,
      'ins' => sub {
        my ($HW,$code) = @_;
        $code->[$code->[$HW->{'i'} + 1]] = $HW->{'IN'};
        $HW->{'i'} += 2;
      },
    },
    '4' => {
      'name' => 'OUT',
      'arity' => 1,
      'ins' => sub {
        my ($HW,$code) = @_;
        $HW->{'OUT'} = v($HW,$code,1);
        $HW->{'i'} += 2;
      },
    },
    '5' => {
      'name' => 'JT',
      'arity' => 2,
      'ins' => sub {
        my ($HW,$code) = @_;
        if ( v($HW,$code,1) != 0) { $HW->{'i'} = v($HW,$code,2); }
        else { $HW->{'i'} += 3; }
      },
    },
    '6' => {
      'name' => 'JF',
      'arity' => 2,
      'ins' => sub {
        my ($HW,$code) = @_;
        if ( v($HW,$code,1) == 0) { $HW->{'i'} = v($HW,$code,2); }
        else { $HW->{'i'} += 3; }
      },
    },
    '7' => {
      'name' => 'STL',
      'arity' => 3,
      'ins' => sub {
        my ($HW,$code) = @_;
        if ( v($HW,$code,1) < v($HW,$code,2) ) {
          $code->[$code->[$HW->{'i'} + 3]] = 1;
        }
        else {
          $code->[$code->[$HW->{'i'} + 3]] = 0;
        }
        $HW->{'i'} += 4;
      }
    },
    '8' => {
      'name' => 'STE',
      'arity' => 3,
      'ins' => sub {
        my ($HW,$code) = @_;
        if ( v($HW,$code,1) == v($HW,$code,2) ) {
          $code->[$code->[$HW->{'i'} + 3]] = 1;
        }
        else {
          $code->[$code->[$HW->{'i'} + 3]] = 0;
        }
        $HW->{'i'} += 4;
      }
    },

   '99' => {
     'name' => 'END',
     'arity' => 0,
     'ins' => sub { undef }
    },
  };

  return $ops->{$op};
}

sub decomp {
  my ($HW,$code) = @_;

  print "\n",'ADDR',"\n";
  for ($HW->{'i'}=0; $HW->{'i'} < @{$code};) {
    $HW->{'i'} += print_line($HW,$code);
  }
  print "\n";
}

sub print_line {
  my ($HW,$code) = @_;

    my $op = op($HW,$code);

    my $i = $HW->{'i'};

    my $len;my $name;
    if (ref ops($op)) {
      $len  = ops($op)->{'arity'} + 1;
      $name = ops($op)->{'name'};
    }
    else { $len = 1; $name = 'DATA'; }

    if (($i + $len) > scalar(@{$code})) { $len = 1; $name = 'DATA'; }

    #print ' $i $len $name @{$code} '," $i $len $name ",scalar(@{$code}),"\n";

    print sprintf("%04d",$HW->{'i'});

    my $j = 0;

    for ( ;($j < $len) && (($i + $j) < @{$code}); $j++ ) {
        print " ",sprintf("%5s",sprintf("%d", $code->[$HW->{'i'} + $j]));
    }
    for ( ;($j < 4) ; $j++) {
        print " ",sprintf("%5s"," ");
    }
    print " ",sprintf("%-5s",$name);

    for ($j = 1 ;($j < $len) && (($i + $j) < @{$code}); $j++ ) {
        print " ",f($HW,$code,$j);
    }
    print "\n";

    return $len;
}

sub code_array2string {
  my ($array) = @_;

  my $string = join(',', @{$array} );
  return $string;
}

sub code_string2array {
  my ($string) = @_;

  my @array = $string =~ m/([-]?\d+)/g;
  return @array;
}





