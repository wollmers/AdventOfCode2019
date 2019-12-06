#!perl

use strict;
use warnings;

use Data::Dumper;

my @input = <>;

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

my $orbits = {};

#print Dumper(@input);

#for my $line (split(/\n/,$example2)) {
for my $line (@input) {
  my ($center,$around) = $line =~ /(\w+)\)(\w+)/;
  $orbits->{$around} = $center;
}

my $count = 0;
for my $orbit (keys %$orbits) {
  $count += count_orbits($orbit);
}
print $count,"\n"; # 117672

my $start = 'YOU';
my $end = 'SAN';
my $start_path = {};
my $start_count = 0;
my $end_count = 0;
my $end_path = {};

path($start,$orbits,$start_path,$start_count);
path($end,$orbits,$end_path,$end_count);

my $result = 0;
my $orbit = $start;
#for my $orbit ($orbit = $start; $orbit) {
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
  else {$orbit = undef}

}
print $result,"\n"; # 277

sub path {
  my ($orbit,$orbits,$path,$count) = @_;
  if (exists $orbits->{$orbit}) {
    $count++;
    $path->{$orbits->{$orbit}} = $count;
    path($orbits->{$orbit},$orbits,$path,$count);
  }
  else { return 0;}
}

sub count_orbits {
  my ($orbit) = @_;
  if (exists $orbits->{$orbit}) {
    return 1 + count_orbits($orbits->{$orbit});
  }
  else { return 0;}
}

