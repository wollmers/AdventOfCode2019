#!perl

use strict;
use warnings;
no warnings 'recursion';

my $example =<<EOF;
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
EOF

my $example2 =<<EOF;
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
EOF


my @input = <>;

my $TEST = 0;
if ($TEST) { @input = split(/\n/,$example2); }

my $orbits = {};
for my $line (@input) {
  my ($center,$around) = $line =~ /(\w+)\)(\w+)/;
  $orbits->{$around} = $center;
}

my $paths = {};

my $paths_count = build_paths($orbits, $paths);

sub build_paths {
  my ($orbits, $paths) = @_;
  my $count = 0;
  for my $orbit (keys %$orbits) {
    $paths->{$orbit} = {};
    $count += path2($orbit, $orbits, $paths->{$orbit});
  }
  return $count;
}

print 'paths_count: ',$paths_count,"\n"; # 117672


my $start = 'YOU';
my $end   = 'SAN';

my $distance = distance($start,$end,$paths,$orbits);

sub distance {
  my ($start,$end,$paths,$orbits) = @_;

  my $result = 0;
  my $orbit = $start;
  my $start_path = $paths->{$start};
  my $end_path   = $paths->{$end};
  while ($orbit) {
    if (exists $orbits->{$orbit}
      && exists $start_path->{$orbit}
      && exists $end_path->{$orbit}
      ) {
      $result = $start_path->{$orbit} + $end_path->{$orbit} - 2;
      last;
    }
    elsif (exists $orbits->{$orbit}) {
      $orbit = $orbits->{$orbit};
    }
    else { $orbit = undef }
  }
  return $result;
}

print "distance $start -> $end ",$distance,"\n"; # 277

# recursive
sub path {
  my ($orbit,$orbits,$path,$count) = @_;
  if (exists $orbits->{$orbit}) {
    $count++;
    $path->{$orbits->{$orbit}} = $count;
    path($orbits->{$orbit},$orbits,$path,$count);
  }
  else { return 0; }
}

# iterative
sub path2 {
  my ($orbit,$orbits,$path) = @_;
  my $count = 0;
  while ($orbit) {
    if (exists $orbits->{$orbit}) {
      $count++;
      $path->{$orbits->{$orbit}} = $count;
      $orbit = $orbits->{$orbit};
    }
    else { return $count; }
  }
}

# not needed, if we use path2
sub count_orbits {
  my ($orbit) = @_;
  if (exists $orbits->{$orbit}) {
    return 1 + count_orbits($orbits->{$orbit});
  }
  else { return 0;}
}

