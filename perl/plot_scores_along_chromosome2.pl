#! /usr.bin/perl

use strict;
use warnings;
use MyUtility;
use Coordinate;

my $dbh = connect_to_mysql("expression_module");

my $outfile = "out.pdf";
my $Chr = 1;
my $start;
my $end ;
my @chrlength = (247249719,242951149,199501827,191273063,180857866,170899992,158821424,146274826,140273252,135374737,134452384,132349534,114142980,106368585,100338915,88827254,78774742,76117153,63811651,62435964,46944323,49691432,154913754,57772954);

my $usage = qq(
usage: $0 file
 
 -o outfile (default is "$outfile")
 -c chromosome (default is "$Chr")
 -s start 
 -e end 

);

get_options({c => \$Chr, s => \$start, e => \$end, o=>\$outfile} ,$usage) or exit;
$Chr =~ s/chr//;
$Chr=~ s/X/23/;
$Chr=~ s/Y/24/;
defined($start) or  $start = 0;
defined($end) or  $end = $chrlength[$Chr-1];
$start = conv_si_prefix_to_number($start)/1000000;
$end = conv_si_prefix_to_number($end)/1000000;

my @data;
open(OUT,">tmp${$}.in");
chop(my @tmp = `cut -f 1,2 $ARGV[0]`) or die;
foreach my $s (@tmp){
  my ($chr,$start2, $end2, $pos,$score);
  my @tmp2 = split("\t", $s);
  ($chr,$start2, $end2)  = my_id2coordinate($tmp2[0]);
  $score = $tmp2[1];
  $chr=~s/chr//;
  $chr=~s/X/23/;
  $chr=~s/Y/24/;
  $chr eq $Chr or next;
  $pos= ($start2 + $end2)/2000000;
  $pos >= $start or next;
  $pos <= $end or next;
  print OUT "$pos\t$score\n";

}

open(SCRIPT,">tmp${$}.R");

print SCRIPT "infile <- '"."tmp${$}.in"."'\n";
print SCRIPT "outfile <- '".$outfile."'\n";
print SCRIPT "x <- c($start , $end )\n";
print SCRIPT << 'EOF';

d<-read.table(infile)
pdf(file=outfile)
plot(d[,1],d[,2], xlim=x, xlab="coordinate(Mbp)", ylab="score")
dev.off()


EOF

system("R  --vanilla --slave < tmp${$}.R > /dev/null");
system("rm tmp${$}.*");
