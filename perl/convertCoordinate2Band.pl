#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);                                     
require LocusMapper;  

my $usage ="usage: $0 [-v geneme_version (default: hg18)] infile\n";
my $version = "hg18";
my $argv = join(" ", @ARGV);
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);

setVersion($version);
readData();

undef($/);
my $in = <>;
$/ = "\n";
my $pos = 0;
while($in =~ /chr[XY\d]+_\d+_\d+/g){
    my ($c, $s, $e) = split("_", $&);
    my $l = length($&);
    my $band = coordinate2band($c, $s, $e);
    print substr($in, $pos, pos($in)-$l-$pos).$band;
    $pos = pos($in);
}
print substr($in, $pos);
