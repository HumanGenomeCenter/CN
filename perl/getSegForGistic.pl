#!/usr/local/bin/perl

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;
set_environment();

my $usage ="usage: $0 segFile probeFile\n";
my $segFile = shift or die $usage;
my $probeFile = shift or die $usage;
system("java  snp.SegmentContainerMap -f  $segFile  > tmp${$}.seg"); 
system("java  snp.SegmentContainerMap -N -p $probeFile tmp${$}.seg");
`rm tmp${$}.seg`;
