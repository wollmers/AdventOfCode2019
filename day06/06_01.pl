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

my $orbits = {};

print Dumper(@input);

#for my $line (split(/\n/,$example)) {
for my $line (@input) {
  my ($center,$around) = $line =~ /(\w+)\)(\w+)/;
  $orbits->{$around} = $center;
}

my $count = 0;
for my $orbit (keys %$orbits) {
  $count += count_orbits($orbit);
}
print $count,"\n"; # 117672

sub count_orbits {
  my ($orbit) = @_;
  if (exists $orbits->{$orbit}) {
    return 1 + count_orbits($orbits->{$orbit});
  }
  else { return 0;}
}

