#! /usr.bin/perl

use strict;
use warnings;

my $outfile = "out.pdf";
my $min;
my $max;
my $usage = qq(usage: $0 file
 -o outfile (default is "$outfile")
);

my $argv = join(" ", @ARGV);
if($argv =~ s/-o\s+(\S+)//){
    $outfile = $1;
}
if($argv =~ s/-m\s+(\S+)//){
    $min = $1;
}
if($argv =~ s/-M\s+(\S+)//){
    $max = $1;
}

@ARGV = split(" ", $argv);
@ARGV or die $usage;

my @data;
open(OUT,">tmp${$}.in");

while(<>){
    my ($chr, $pos,$score)  = split("\t");
    $chr=~s/chr//;
    $chr=~s/X/23/;
    $chr=~s/Y/24/;
    $chr =~ /\d+/ or next;
    $chr >= 0 and $chr <= 24 or next;
    if(defined($min) and $score < $min){
        $score = $min;
    }
    if(defined($max) and $score > $max){
        $score = $max;
    }
    print OUT "$chr\t$pos\t$score\n";
}

open(SCRIPT,">tmp${$}.R");

print SCRIPT "infile <- '"."tmp${$}.in"."'\n";
print SCRIPT "outfile <- '".$outfile."'\n";

print SCRIPT << 'EOF';

#############################################
#read input
#############################################

tmp<-read.table(infile)
chr<-as.numeric(tmp[,1])
pos<-as.numeric(tmp[,2])
score<-as.numeric(tmp[,3])

#############################################
# plot
#############################################

chrInterval <-1000000

chrLevel<-as.numeric(levels(factor(chr)))

pos2<-NULL
preEnd<-0
for(i in 1:length(chrLevel)){
  tmp<-pos[chr==chrLevel[i]]
  tmp<-tmp-min(tmp)
  tmp<-tmp+preEnd
  pos2<-c(pos2,tmp)
  preEnd<-pos2[length(pos2)]+chrInterval
}

even<-chrLevel[chrLevel/2==as.integer(chrLevel/2)]
odd<-chrLevel[chrLevel/2!=as.integer(chrLevel/2)]

plotScore<-function(S,col="red",ylab="qvalue"){
  ymax<-max(S)
  parTmp<-par("fin")
  par(fin=c(parTmp[1], parTmp[2]/2))
  plot(NA, xlab="position", ylab=ylab,  xlim=c(0,max(pos2)),ylim=c(0,ymax))

  for(i in 1:length(even)){
      par(new=T)
      xmin<-min(pos2[chr==even[i]])
      xmax<-max(pos2[chr==even[i]])
      polygon(c(xmin,xmax,xmax,xmin), c(0,0,ymax,ymax), col = "gray",border=NA)
  }
 
  par(new=T)
  plot(pos2,S,xlim=c(0,max(pos2)),ylim=c(0,ymax),ann=FALSE, axes=FALSE, col=col,type = "l") 
  par(fin=parTmp)
}

pdf(outfile)
plotScore(score, ylab="score")
dev.off()

EOF

system("R  --vanilla --slave < tmp${$}.R > /dev/null");
system("rm tmp${$}.*");
