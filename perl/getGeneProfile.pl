#!/usr/local/bin/perl

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;
set_environment();

my $usage ="usage: $0 [-v geneme_version (default: hg18)] segFile\n";
my $version = "hg18";
my $argv = join(" ", @ARGV);
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);
my $segFile = shift or die $usage;
my $bedFile = get_home_dir()."/data/symbol.${version}.bed";

system("java  snp.SegmentContainerMap -M -b $bedFile $segFile");
