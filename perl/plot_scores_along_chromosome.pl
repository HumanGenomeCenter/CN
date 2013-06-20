#! /usr.bin/perl

use strict;
use warnings;
use MyUtility;
use Coordinate;


my $outfile = "out.pdf";
my $grad = 1; 
my $usage = qq(
usage: $0 file
 
 -o outfile (default is "$outfile")
 -g gradation (default is on)   	       
);

get_options({o=>\$outfile,g=>\$grad} ,$usage) or exit;

my @data;
open(OUT,">tmp${$}.in");


chop(my @tmp = `cut -f 1,2 $ARGV[0]`) or die;

foreach my $s (@tmp){
  
  my ($chr,$start, $end, $pos,$score);
  my @tmp2 = split("\t", $s);
  ($chr,$start, $end)  = my_id2coordinate($tmp2[0]);
  $score = $tmp2[1];
  $chr=~s/chr//;
  $chr=~s/X/23/;
  $chr=~s/Y/24/;
  $pos= ($start + $end)/2;
  print OUT "$chr\t$pos\t$score\n";
}

open(SCRIPT,">tmp${$}.R");

print SCRIPT "infile <- '"."tmp${$}.in"."'\n";
print SCRIPT "outfile <- '".$outfile."'\n";
print SCRIPT 'grad <- '.$grad."\n";

print SCRIPT << 'EOF';

d<-read.table(infile)	

chr<-d[,1]
pos<-d[,2]
score<-d[,3]

chrlength<-c(247249719,242951149,199501827,191273063,180857866,170899992,158821424,146274826,140273252,135374737,134452384,132349534,114142980,106368585,100338915,88827254,78774742,76117153,63811651,62435964,46944323,49691432,154913754,57772954)
chrlengthM<-chrlength/1000000
pos<-pos/chrlength[chr]

pdf(file=outfile)
plot(0:100,0:100, type="n",ann=F,axes=F)

if(grad==0){

for(i in 1:length(chr)){
y<-4*chr[i];
x<-10+(90*chrlength[chr[i]]/chrlength[1])*pos[i]
segments(x,y+1.5,x,y-1.5,col="red");
}

for(i in 1:24){
  segments(10,4*i,10+90*chrlength[i]/chrlength[1],4*i,col="gray50",lty=3)
}	
for(i in 1:22){
  text(2,4*i,paste("chr",i,sep=""))
}	
text(2,4*23,"chrX")
text(2,4*24,"chrY")

}else{

library(marray)
my.col <- function(n){
  #rev(brewer.pal(n,"RdYlBu")) 
  #maPalette(low = "blue1", high = "red1", mid = "white", k = n)
  #maPalette(low = "royalblue1", high = "tomato1", mid = "antiquewhite1", k = n)
  maPalette(low = "white", high = "red1", k = n)
  #maPalette(low = "white", high = "firebrick2", k = n)
}
Col<-my.col(100)
Col<-c(Col,Col[length(Col)])	

min<-min(score)
max<-max(score)

col<-Col[(length(Col)-1)*(score-min)/(max-min)+1] 


for(i in 1:length(chr)){
y<-4*chr[i];
x<-10+(90*chrlength[chr[i]]/chrlength[1])*pos[i]
segments(x,y+1.5,x,y-1.5,col=col[i]);
}


for(i in 1:24){
  segments(10,4*i,10+90*chrlength[i]/chrlength[1],4*i,col="gray50",lty=3)
}	
for(i in 1:22){
  text(2,4*i,paste("chr",i,sep=""))
}	
text(2,4*23,"chrX")
text(2,4*24,"chrY")

y_top<-95
y_bottom<-65
x_left<-90
x_right<-95

for(i in 1:(length(Col)-1)){
 rect(x_left,y_bottom+(y_top-y_bottom)*(i-1)/(length(Col)-1),x_right,y_bottom+(y_top-y_bottom)*i/(length(Col)-1),col=Col[i],border=FALSE)
}	

text((x_left+x_right)*0.5,y_top+2,max(score))
text((x_left+x_right)*0.5,y_bottom-2,min(score))

}

dev.off()


EOF

system("R  --vanilla --slave < tmp${$}.R > /dev/null");
system("rm tmp${$}.*");
