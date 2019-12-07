#!perl

use strict;
use warnings;

use Data::Dumper;

my $input = <>;



my $tests2 = [

[ [9,8,7,6,5],139629729,[3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5],],

[ [9,7,8,5,6],18216,[3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10],],

];

my $tests = [

[ [4,3,2,1,0],43210,[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0],],

[ [0,1,2,3,4],54321,[3,23,3,24,1002,24,10,24,1002,23,-1,23,
101,5,23,23,1,24,23,23,4,23,99,0,0],],

[ [1,0,4,3,2],65210,[3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0],],

];

my $amps = {
  #'0'    => {'next' => 'AmpA', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  'AmpA' => {'next' => 'AmpB', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  'AmpB' => {'next' => 'AmpC', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  'AmpC' => {'next' => 'AmpD', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  'AmpD' => {'next' => 'AmpE', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  'AmpE' => {'next' => 'Thru', 'HW' => {}, 'code' => [],'phase_setting' => undef,},
  #'Thru' => {'next' => '',     'HW' => {}, 'code' => [],'phase_setting' => undef,},
};

my $code = [];
my $HW = {'IN' => '', 'OUT' => '', 'i' => 0, 'p1' => 0, 'p2' => 0, 'p3' => 0, 'debug' => 0, 'halt' => 0, 'wait' => 1,};

if (0) {
my $test_count = 0;
my $test_skip = 0;
my $test_limit = 999;
for my $test (@$tests2) {
  $test_count++;
  next if ($test_count <= $test_skip);
  last if ($test_count > $test_limit);
  my $input = join(',',@{$test->[2]});
  my $setting = $test->[0];
  my $result = try_setting2($amps,$setting,$input);

  #decomp($HW,$code);
  if ($result == $test->[1]) {
    print "$test_count OK \n";
  }
  else {
    print "$test_count FAIL expexted $test->[1] got $result \n";
    #print 'IN OUT ',"$HW->{'IN'} $HW->{'OUT'} \n";
    #print '@{$code} ',join(' ',@{$code}),"\n";
  }
}
}

sub try_setting2 {
  my ($amps,$setting,$input) = @_;

  my $last_out = 0;
  my $phase = 0;
  for my $amp (sort keys %$amps) {
    my $HW = $amps->{$amp}->{'HW'};
    $HW->{'IN'} = $setting->[$phase];
    $HW->{'OUT'} = -999;
    $HW->{'i'} = 0;
    $HW->{'halt'} = 0;
    #if ($phase == 0) {$HW->{'IN'} = 0}
    #$HW->{'IN'} = $last_out;
    my $code = $amps->{$amp}->{'code'};
    @{$code} = $input =~ m/([-]?\d+)/g;
    #print 'step1: ',"$amp $HW->{'IN'} ","\n";
    $HW->{'wait'} = 0;
    runit($HW,$code);
    $last_out = $HW->{'OUT'};
    $phase++;
    #print 'step1: ',"$amp $HW->{'i'} $HW->{'IN'} $HW->{'OUT'}","\n";
  }
  #decomp($HW,$code);
  #$HW->{'debug'} = 1;

  for my $amp (sort keys %$amps) {
    my $HW = $amps->{$amp}->{'HW'};
    $HW->{'IN'} = $last_out;
    if ($amp eq 'AmpA') {$HW->{'IN'} = 0;}
    my $code = $amps->{$amp}->{'code'};
    $HW->{'wait'} = 0;
    runit($HW,$code);
    $last_out = $HW->{'OUT'};
  }

  my $count = 0;
  while (!$amps->{'AmpE'}->{'HW'}{'halt'}) {
    #$count++;
    #print $count,"\n";
    for my $amp (sort keys %$amps) {
      my $HW = $amps->{$amp}->{'HW'};
      $HW->{'IN'} = $last_out;
      #if ($amp eq 'AmpA') {$HW->{'IN'} = 0;}
      my $code = $amps->{$amp}->{'code'};
      $HW->{'wait'} = 0;
      runit($HW,$code);
      $last_out = $HW->{'OUT'};
    }
  }
  return $last_out;
}

sub try_setting {
  my ($amps,$setting,$input) = @_;

  my $phase = 0;
  for my $amp (sort keys %$amps) {
    my $HW = $amps->{$amp}->{'HW'};
    $HW->{'IN'} = $setting->[$phase];
    $HW->{'OUT'} = -999;
    $HW->{'i'} = 0;
    my $code = $amps->{$amp}->{'code'};
    @{$code} = $input =~ m/([-]?\d+)/g;
    #print 'step1: ',"$amp $HW->{'IN'} ","\n";
    step($HW,$code);
    $phase++;
    #print 'step1: ',"$amp $HW->{'i'} $HW->{'IN'} $HW->{'OUT'}","\n";
  }
  #decomp($HW,$code);
  #$HW->{'debug'} = 1;
  my $last_out = 0;
  for my $amp (sort keys %$amps) {
    my $HW = $amps->{$amp}->{'HW'};
    $HW->{'IN'} = $last_out;
    my $code = $amps->{$amp}->{'code'};
    runit($HW,$code);
    $last_out = $HW->{'OUT'};
  }
  return $last_out;
}

#exit;
if (1) {

  my $max_result = -1;

  my $used = {};
  my $count = 0;

  #while ($count <= 3125) { # 5^5

  for my $n0 (5..9) {
    for my $n1 (5..9) {
      for my $n2 (5..9) {
        for my $n3 (5..9) {
          for my $n4 (5..9) {
            my $number = join('',($n0,$n1,$n2,$n3,$n4));
            $used->{$number}++;
          }
        }
      }
    }
  }

  for my $number (sort keys %$used) {
    if ($number =~ /(.).*\1+/) { next; }
    my $setting = [split('',$number)];
    print join(',',@$setting),"\n";
    my $result = try_setting2($amps,$setting,$input);
    if ($max_result < $result) {$max_result = $result;}
  }

  print $max_result,"\n"; # 69816958
}

if (0) {

  my $max_result = -1;

  my $used = {};
  my $count = 0;

  #while ($count <= 3125) { # 5^5

  for my $n0 (0..4) {
    for my $n1 (0..4) {
      for my $n2 (0..4) {
        for my $n3 (0..4) {
          for my $n4 (0..4) {
            my $number = join('',($n0,$n1,$n2,$n3,$n4));
            $used->{$number}++;
          }
        }
      }
    }
  }

  for my $number (sort keys %$used) {
    if ($number =~ /(.).*\1+/) { next; }
    my $setting = [split('',$number)];
    print join(',',@$setting),"\n";
    my $result = try_setting($amps,$setting,$input);
    if ($max_result < $result) {$max_result = $result;}
  }

  print $max_result,"\n"; # 12540 too low; 668340 too high; 21760
}

if (0) {
$HW->{'IN'} = '5';
$HW->{'OUT'} = '';
$HW->{'i'} = 0;

@{$code} = $input =~ m/([-]?\d+)/g;
#print Dumper($code);
runit($HW,$code);

print $HW->{'OUT'},"\n"; # 11826654
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

    print sprintf("%04d",$HW->{'i'});

    my $len;my $name;
    if (ref ops($op)) {
      $len  = ops($op)->{'arity'} + 1;
      $name = ops($op)->{'name'};
    }
    else { $len = 1; $name = ''; }

    my $j = 0;
    for ( ;$j < $len; $j++ ) {
        print " ",sprintf("%5s",sprintf("%d", $code->[$HW->{'i'} + $j]));
    }
    for ( ;$j < 4; $j++) {
        print " ",sprintf("%5s"," ");
    }
    print " ",sprintf("%-5s",$name);

    for ($j = 1 ;$j < $len; $j++ ) {
        print " ",f($HW,$code,$j);
    }
    print "\n";

    return $len;
}

sub step1 {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',' IN: ',$HW->{'IN'},"\n";
    print 'ADDR',"\n";
  }

    my $op = op($HW,$code);

    if ($HW->{'debug'} > 0) { print_line($HW,$code); }

    ops($op)->{'ins'}->($HW,$code);

}

sub runit1 {
  my ($HW,$code) = @_;

  if ($HW->{'debug'} > 0) {
    print "\n",'DEBUG',' IN: ',$HW->{'IN'},"\n";
    print 'ADDR',"\n";
  }

  for ($HW->{'i'}=0; $HW->{'i'} < @{$code}; ) {

    my $op = op($HW,$code);

    if ($HW->{'debug'} > 0) { print_line($HW,$code); }

    if ($op == 99) { last; }
    #print 'i op: ',"$HW->{'i'},$op","\n";
    ops($op)->{'ins'}->($HW,$code);

  }
}

sub step {
  my ($HW,$code) = @_;

  #for ($HW->{'i'}=0; $HW->{'i'} < @{$code}; ) {

    #my $op = op($code->[$HW->{'i'}],$HW);
    my $op = op($HW,$code);

    if ($op == 99) { $HW->{'halt'} = 1; return; }

    elsif ($op == 1) {
      $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) + v($HW,$code,2);
      $HW->{'i'} += 4;
    }
    elsif ($op == 2) {
      $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) * v($HW,$code,2);
      $HW->{'i'} += 4;
    }
    elsif ($op == 3) {
      $code->[$code->[$HW->{'i'} + 1]] = $HW->{'IN'};
      $HW->{'i'} += 2;
    }
    elsif ($op == 4) {
      $HW->{'OUT'} = v($HW,$code,1);
      $HW->{'i'} += 2;
    }
    elsif ($op == 5) {
      if ( v($HW,$code,1) != 0) { $HW->{'i'} = v($HW,$code,2); }
      else { $HW->{'i'} += 3; }
    }
    elsif ($op == 6) {
      if ( v($HW,$code,1) == 0) { $HW->{'i'} = v($HW,$code,2); }
      else { $HW->{'i'} += 3; }
    }
    elsif ($op == 7) {
      if ( v($HW,$code,1) < v($HW,$code,2) ) {
        $code->[$code->[$HW->{'i'} + 3]] = 1;
      }
      else {
        $code->[$code->[$HW->{'i'} + 3]] = 0;
      }
      $HW->{'i'} += 4;
    }
    elsif ($op == 8) {
      if ( v($HW,$code,1) == v($HW,$code,2) ) {
        $code->[$code->[$HW->{'i'} + 3]] = 1;
      }
      else {
        $code->[$code->[$HW->{'i'} + 3]] = 0;
      }
      $HW->{'i'} += 4;
    }
  #}
}

sub runit {
  my ($HW,$code) = @_;

  for ( ; $HW->{'i'} < @{$code}; ) {

    #my $op = op($code->[$HW->{'i'}],$HW);
    my $op = op($HW,$code);

    if ($op == 99) { $HW->{'halt'} = 1; return; }

    elsif ($op == 1) {
      $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) + v($HW,$code,2);
      $HW->{'i'} += 4;
    }
    elsif ($op == 2) {
      $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) * v($HW,$code,2);
      $HW->{'i'} += 4;
    }
    elsif ($op == 3) {
      if ($HW->{'wait'}) {return;}
      $code->[$code->[$HW->{'i'} + 1]] = $HW->{'IN'};
      $HW->{'i'} += 2;
      $HW->{'wait'} = 1;
    }
    elsif ($op == 4) {
      $HW->{'OUT'} = v($HW,$code,1);
      $HW->{'i'} += 2;
    }
    elsif ($op == 5) {
      if ( v($HW,$code,1) != 0) { $HW->{'i'} = v($HW,$code,2); }
      else { $HW->{'i'} += 3; }
    }
    elsif ($op == 6) {
      if ( v($HW,$code,1) == 0) { $HW->{'i'} = v($HW,$code,2); }
      else { $HW->{'i'} += 3; }
    }
    elsif ($op == 7) {
      if ( v($HW,$code,1) < v($HW,$code,2) ) {
        $code->[$code->[$HW->{'i'} + 3]] = 1;
      }
      else {
        $code->[$code->[$HW->{'i'} + 3]] = 0;
      }
      $HW->{'i'} += 4;
    }
    elsif ($op == 8) {
      if ( v($HW,$code,1) == v($HW,$code,2) ) {
        $code->[$code->[$HW->{'i'} + 3]] = 1;
      }
      else {
        $code->[$code->[$HW->{'i'} + 3]] = 0;
      }
      $HW->{'i'} += 4;
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
  my ($HW,$code) = @_;

  my $op = $code->[$HW->{'i'}];
  my ($instr) = $op =~ /(\d\d?)$/;
  $op =~ s/(\d\d?)$//;

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

  # immediate (literal) mode set ? litteral : value at address
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
        $code->[$code->[$HW->{'i'} + 3]] = v($HW,$code,1) + v($HW,$code,2);
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



