#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $segalpha = 0.001;

my $usage = "usage: $0 [-a alpha] cgh.tab probeInfo.tsv\n";
my $argv = join(" ", @ARGV);
if($argv =~ s/-a\s+([\d.]+)//){
    $segalpha  = $1;
}
@ARGV = split(" ", $argv);

my $cgh = shift or die $usage;
my $probeInfo = shift or die $usage;

-s $cgh and -s $probeInfo or die $usage; 

my $out = "tmp${$}.seg";

chomp(my $tmp = `head -1 $cgh`);
my @sample = split("\t", $tmp);
shift(@sample);

open(IN, $probeInfo);

my %chr;
my %pos;

#<IN>;
while(<IN>){
    chomp;
    my @tmp = split("\t");
    $chr{$tmp[0]} = $tmp[1];
    $pos{$tmp[0]} = $tmp[2];
}

chomp(my @tmp = `cut -f 1 $cgh`);
shift(@tmp);

open(IN, "$cgh");
open(OUT, ">tmp${$}.tab");

$tmp = <IN>;
@tmp = split("\t", $tmp);
print OUT join("\t", ("probe", "chr", "pos", @tmp[1..$#tmp]));
my @id;
while(<IN>){
    @tmp = split("\t");
    my $id = shift(@tmp);
    $chr{$id} or next;
    print OUT join("\t", ($id, $chr{$id}, $pos{$id}, @tmp))."\n";  
}

open(OUT, ">tmp${$}.R");

print OUT 'library(DNAcopy)'."\n";
print OUT 'E<- as.matrix(read.table("'."tmp${$}.tab".'",row.names=1,sep="\t",quote="",header=T))'."\n";
print OUT 'C <-CNA(E[,3:ncol(E)],E[,1], E[,2], sampleid=colnames(E)[3:ncol(E)]) '."\n";
print OUT 'S <-segment(C, alpha='.$segalpha.') '."\n";
print OUT 'write.table(S$out,"'.$out.'", sep="\t", quote=F, row.names=F) '."\n"; 

close(OUT);

`R --vanilla < tmp${$}.R`;

open(IN, $out);
while(<IN>){
    print $_;
}
close(IN);

`rm tmp${$}.*`;
