package IntEmu;

use 5.010;
use strict;
use warnings;


sub new {
  my $class = shift;
  # uncoverable condition false
  my $self = bless {
    'IN'    => [],
    'OUT'   => [],
    'i'     => 0,
    'p1'    => 0,
    'p2'    => 0,
    'p3'    => 0,
    'debug' => 0,
    'halt'  => 0,
    'wait'  => 0,
    'base'  => 0,
    'code'  => [],
    'alloc_first' => 0,
    'alloc_last'  => 0,
  }, $class;
}


sub runit {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',
    ' IN: [',join(',',@{$HW->{'IN'}}),']',
    ' OUT: [',join(',',@{$HW->{'OUT'}}),']',
    "\n";
    print 'ADDR',"\n";
  }

  for ( ; $HW->{'i'} < @{$code}; ) {

    my $op = op($HW,$code);
    if ($HW->{'debug'} > 0) { print_line($HW,$code); }
    if ($op == 99) {
      $HW->{'halt'} = 1;
      if ($HW->{'debug'} > 0) {
        print 'DEBUG',
        ' IN: [',join(',',@{$HW->{'IN'}}),']',
        ' OUT: [',join(',',@{$HW->{'OUT'}}),']',
        "\n";
      }
      return;
    }
    elsif ($op == 3) {
      if ($HW->{'wait'}) { return; }
      ops($op)->{'ins'}->($HW,$code);
      $HW->{'wait'} = 1;
    }
    else {
      if (defined ops($op)) {
        ops($op)->{'ins'}->($HW,$code);
      }
      else {
        say 'undefined op: ',$op,' at addr ',$HW->{'i'};
        return;
      }
    }
  }
}

sub step {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',' IN: [',join(',',@{$HW->{'IN'}}),"]\n";
    print 'ADDR',"\n";
  }

  my $op = op($HW,$code);

  if ($HW->{'debug'} > 0) { print_line($HW,$code); }

  ops($op)->{'ins'}->($HW,$code);
}

sub alloc {
  my ($HW,$code,$cells) = @_;
  #my $end = $HW->{'alloc_first'} + $HW->{'alloc_last'};
  for (my $i=0;$i<$cells;$i++) {
    $code->[$HW->{'alloc_last'} + $i + 1] = 0;
  }
  $HW->{'alloc_last'} += $cells;
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

sub a {
  my ($HW,$code,$p) = @_;

  my $px = 'p' . $p;

  # immediate (literal) mode set ? litteral : value at address
  #my $val = $HW->{$px} ? $code->[$HW->{'i'} + $p] : $code->[$code->[$HW->{'i'} + $p]];

  my $addr = 0;
  if ($HW->{$px} == 0)    { $addr = $code->[$HW->{'i'} + $p]; }
  elsif ($HW->{$px} == 1) { $addr = $HW->{'i'} + $p; }
  elsif ($HW->{$px} == 2) { $addr = $HW->{'base'} + $code->[$HW->{'i'} + $p]; }

  if ($addr < 0) { say 'ERROR addr: ',$addr,' < 0 is outside memory'; }
  elsif ($addr > $HW->{'alloc_last'}) {
    say 'ERROR addr: ',$addr,' outside memory last: ',$HW->{'alloc_last'};
    alloc($HW, $code, $addr - $HW->{'alloc_last'});
  }
  return $addr;
}

sub v {
  my ($HW,$code,$p) = @_;

  return $code->[a(@_)];
}

sub f {
  my ($HW,$code,$p) = @_;

  my $px = 'p' . $p;

  # immediate (literal) mode set ? literal : value at address
  #my $val = $HW->{$px} ? $code->[$HW->{'i'} + $p] : '*' . $code->[$HW->{'i'} + $p];

  my $val = 0;
  if    ($HW->{$px} == 0) { $val = '*' . $code->[$HW->{'i'} + $p]; }
  elsif ($HW->{$px} == 1) { $val = $code->[$HW->{'i'} + $p]; }
  elsif ($HW->{$px} == 2) { $val = 'b+(' . $code->[$HW->{'i'} + $p] . ')'; }

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
        $code->[a($HW,$code,3)] = v($HW,$code,1) + v($HW,$code,2);
        $HW->{'i'} += 4;
      },
    },
    '2' => {
      'name' => 'MULT',
      'arity' => 3,
      'ins' => sub {
        my ($HW,$code) = @_;
        $code->[a($HW,$code,3)] = v($HW,$code,1) * v($HW,$code,2);
        $HW->{'i'} += 4;
      }
    },
    '3' => {
      'name' => 'IN',
      'arity' => 1,
      'ins' => sub {
        my ($HW,$code) = @_;
        $code->[a($HW,$code,1)] = shift @{$HW->{'IN'}};
        $HW->{'i'} += 2;
      },
    },
    '4' => {
      'name' => 'OUT',
      'arity' => 1,
      'ins' => sub {
        my ($HW,$code) = @_;
        push @{$HW->{'OUT'}},v($HW,$code,1);
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
          $code->[a($HW,$code,3)] = 1;
        }
        else {
          $code->[a($HW,$code,3)] = 0;
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
          $code->[a($HW,$code,3)] = 1;
        }
        else {
          $code->[a($HW,$code,3)] = 0;
        }
        $HW->{'i'} += 4;
      }
    },
    '9' => {
      'name' => 'BASE',
      'arity' => 1,
      'ins' => sub {
        my ($HW,$code) = @_;
        my $value = v($HW,$code,1);
        $HW->{'base'} = $HW->{'base'} + v($HW,$code,1);
        $HW->{'i'} += 2;
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
  #for ($HW->{'i'}=0; $HW->{'i'} < @{$code};) {
  for ($HW->{'i'}=0; $HW->{'i'} <= $HW->{'alloc_last'};) {
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
        print " ",sprintf("%8s",sprintf("%d", $code->[$HW->{'i'} + $j]));
    }
    for ( ;($j < 4) ; $j++) {
        print " ",sprintf("%8s"," ");
    }
    print " ",sprintf("%-8s",$name);

    for ($j = 1 ;($j < $len) && (($i + $j) < @{$code}); $j++ ) {
        print " ",f($HW,$code,$j);
    }
    if ($HW->{'debug'}) {
      print " base: ",$HW->{'base'};
      for (my $i=1;$i<$len;$i++) {
        print " v$i: ",v($HW,$code,$i);
      }
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

1;
