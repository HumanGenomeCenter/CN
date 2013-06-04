#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $inFile = shift or die "usage: $0 segFile (chainFile)\n";
my $chainFile = shift;
$chainFile or $chainFile = get_home_dir()."/liftover/hg18ToHg19.over.chain";

open(IN,$inFile);
my $binSize = 10000;
my $tmp = <IN>;
print  $tmp;

open (OUT, ">tmp${$}.out");
while(<IN>){
    chomp;
    my @tmp = split("\t");
    if($tmp[1] eq "23"){
	$tmp[1] = "X";
    }
    if($tmp[1] eq "24"){
	$tmp[1] = "Y";
    }
    $tmp[1] = "chr".$tmp[1];
    


    my ($c, $s, $e)  = @tmp[1..3];
    for(my $i =  $s; $i < $e; $i+=$binSize){
	print OUT join("\t",($c, $i, min($i+$binSize-1, $e), join(":::::",@tmp[0,4..$#tmp])))."\n";
    }
}

my $command = get_home_dir()."/liftover/liftOver tmp${$}.out $chainFile  tmp${$}.out2   /dev/null";
`$command`;


open(IN,  "tmp${$}.out2");

my @preData;
my @preCoord;
while(<IN>){
    chomp;
    my @tmp = split("\t");
    $tmp[0] =~  s/chr//;
    if($tmp[0] eq "X"){
	$tmp[0] = 23;
    }
    if($tmp[0] eq "Y"){
	$tmp[0] = 24;
    }
    my @coord = @tmp[0..2];

    my @data = split(":::::",$tmp[3]);


    #print join("\t",($data[0],  @coord, @data[1..$#data]))."\n";


    #next;

    unless(@preCoord){
	@preCoord = @coord;
	@preData = @data;
	next;
    }



    if($preCoord[0] eq $coord[0]  and  $preCoord[2]+1 == $coord[1] and is_equal(\@preData, \@data)){
	@preCoord = (@preCoord[0,1],$coord[2]); 
	next;
    }


    print join("\t",($preData[0],  @preCoord, @preData[1..$#preData]))."\n";
    @preCoord = @coord;
    @preData = @data;

 
   
}
print join("\t",($preData[0],  @preCoord, @preData[1..$#preData]))."\n";
`rm tmp${$}.out*`; 


sub min {
    my $min = shift;
    foreach ( @_ ){ $min = $_ if $_ < $min }
    return $min;
}


sub is_equal{
    my ($a,$b) = @_;
    if(@$a ne @$b){
        return 0;
    }
    for(0..$#$a){
        if($a->[$_] ne $b->[$_]){
            return 0;
        }
    }
    return 1;
}
