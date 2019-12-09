#!perl
use 5.010;
use strict;
use warnings;
use lib './lib';

use IntEmu;

use Data::Dumper;

#my $input = <>;


my $tests = [
#  p1 p2        0    1   2   3  4   5   6   7  8  9
[ [    ], 0,[1101,   0,  0,  9, 4,  9, 99,  0, 0, 9],'ADD lit 1'],
[ [    ], 3,[1101,   1,  2,  9, 4,  9, 99,  0, 0, 9],'ADD lit 2'],
[ [    ],-1,[1101,   1, -2,  9, 4,  9, 99,  0, 0, 9],'ADD lit 3'],

[ [    ], 0,[   1,   7,  8,  9, 4,  9, 99,  0, 0, 9],'ADD adr 1'],
[ [    ], 3,[   1,   7,  8,  9, 4,  9, 99,  1, 2, 9],'ADD adr 2'],
[ [    ],-1,[   1,   7,  8,  9, 4,  9, 99,  1,-2, 9],'ADD adr 3'],

[ [    ], 0,[1102,   0,  0,  9, 4,  9, 99,  0, 0, 9],'MULT lit 1'],
[ [    ], 2,[1102,   1,  2,  9, 4,  9, 99,  0, 0, 9],'MULT lit 2'],
[ [    ],-2,[1102,   1, -2,  9, 4,  9, 99,  0, 0, 9],'MULT lit 3'],

[ [    ], 0,[   2,   7,  8,  9, 4,  9, 99,  0, 0, 9],'MULT adr 1'],
[ [    ], 2,[   2,   7,  8,  9, 4,  9, 99,  1, 2, 9],'MULT adr 2'],
[ [    ],-2,[   2,   7,  8,  9, 4,  9, 99,  1,-2, 9],'MULT adr 3'],

#  p1 p2        0    1   2   3  4   5   6   7  8  9  10 11 12
[ [1   ], 1,[   3,   7,  4,  7, 99, 1, -2,  9],'IN adr 1'],

[ [    ], 1,[ 104,   1, 99,  1,-2, 9],'OUT lit 1'],
[ [    ], 1,[   4,   3, 99,  1,-2, 9],'OUT adr 2'],

#  p1 p2         0    1   2   3   4   5    6  7   8   9  10 11 12
[ [    ], 1,[ 1105,   1,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JT lit 1'],
[ [    ], 0,[ 1105,   0,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JT lit 2'],

[ [    ], 1,[    5,   9, 10, 104, 0, 99, 104, 1, 99,  1,  6, 9],'JT adr 1'],
[ [    ], 0,[    5,   9, 10, 104, 0, 99, 104, 1, 99,  0,  6, 9],'JT adr 2'],

#  p1 p2         0    1   2   3   4   5    6  7   8   9  10 11 12
[ [    ], 1,[ 1106,   0,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JF lit 1'],
[ [    ], 0,[ 1106,   1,  6, 104, 0, 99, 104, 1, 99,  1, -2, 9],'JF lit 2'],

[ [    ], 1,[    6,   9, 10, 104, 0, 99, 104, 1, 99,  0,  6, 9],'JF adr 1'],
[ [    ], 0,[    6,   9, 10, 104, 0, 99, 104, 1, 99,  1,  6, 9],'JF adr 2'],

#  p1 p2         0    1   2   3    4   5    6    7   8   9  10 11 12
[ [    ], 1,[ 1107,   0,  6,  7,   4,  7,  99,   0, -2, 9],'STL lit 1'],
[ [    ], 0,[ 1107,   6,  0,  7,   4,  7,  99,   1, -2, 9],'STL lit 2'],

[ [    ], 1,[    7,   7,  8,  9,   4,  9,  99,   0,  6, 9],'STL adr 1'],
[ [    ], 0,[    7,   7,  8,  9,   4,  9,  99,   6,  0, 9],'STL adr 2'],

# STE
#  p1 p2         0    1   2   3    4   5    6    7   8   9  10 11 12
[ [    ], 1,[ 1108,   6,  6,  7,   4,  7,  99,   0, -2, 9],'STE lit 1'],
[ [    ], 0,[ 1108,   6,  7,  7,   4,  7,  99,   1, -2, 9],'STE lit 2'],

[ [    ], 1,[    8,   7,  8,  9,   4,  9,  99,   6,  6, 9],'STE adr 1'],
[ [    ], 0,[    8,   7,  8,  9,   4,  9,  99,   6,  7, 9],'STE adr 2'],

];


if (1) {
  my $test_count = 0;
  my $test_skip  = 0;
  my $test_limit = 999;

  for my $test (@$tests) {
    $test_count++;
    next if ($test_count <= $test_skip);
    last if ($test_count > $test_limit);

    my $HW   = IntEmu->new;
    #%{$HW}   = %{$HW_init};

    my $code = $HW->{'code'};
    @{$code} = @{$test->[2]};

    $HW->{'alloc_first'} = scalar @{$code};
    $HW->{'alloc_last'}  = $HW->{'alloc_first'};

    #$HW->{'IN'} = $test->[0][0];
    push @{$HW->{'IN'}},$test->[0][0] if (@{$test->[0]});

    #$HW->{'debug'} = 1;

    #runit($HW,$code);
    $HW->runit($code);

    #my $result = $HW->{'OUT'};
    #my $result = join(',',@{$HW->{'OUT'}});
    my $result = shift @{$HW->{'OUT'}};

    if ($result == $test->[1]) {
      print "$test_count OK - ",$test->[3],"\n";
    }
    else {
      print "$test_count FAIL - expected ",$test->[1]," got $result - ",$test->[3],"\n";
    }
  }
}

=pod
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
=cut

