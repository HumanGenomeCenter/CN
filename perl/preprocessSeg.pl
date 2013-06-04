#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;
my $HOME = get_home_dir();

@ARGV or die "usage: $0 [-v geneme_version (default: hg18)] X.seg Y.seg ...\n";
my $version = "hg18";
my $argv = join(" ", @ARGV);
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);

foreach(@ARGV){
    -f $_ or next;
    /(.*)\.seg/  or next;
    my $tmp = $1;
    $tmp =~ /\.filled$/ and next;
    warn "processing $_ ...\n";
    if(system("perl $HOME/perl/segment.pl  -f ${tmp}.seg > ${tmp}.filled.seg")){
	system("perl $HOME/perl/segment.pl -F 2 ${tmp}.seg > ${tmp}.filled.seg") and next; 
    }
    system("perl $HOME/perl/segment.pl  -M -n 1000  ${tmp}.filled.seg >  ${tmp}.1000.tab") and next;
    system("perl $HOME/perl/segment.pl  -M -n 3000  ${tmp}.filled.seg >  ${tmp}.3000.tab") and next;
    system("perl $HOME/perl/getGeneProfile.pl -v $version ${tmp}.filled.seg > ${tmp}.gene.tab") and next;
    system("perl $HOME/perl/getArmProfile.pl -v $version  ${tmp}.filled.seg > ${tmp}.arm.tab") and next; 
}
