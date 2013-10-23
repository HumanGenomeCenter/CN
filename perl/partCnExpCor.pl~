#!/usr/local/bin/perl

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $usage = "usage: $0 [-p minus_log_pvalue_cutoff (default: 3)] peakCN.tab peakGeneset.gmt exp.tab\n";

my $pcutoff = 3;
my $argv = join(" ", @ARGV);
if($argv =~ s/-p\s+(\S+)//){
    $pcutoff = $1;
}
@ARGV = split(" ", $argv);

my $HOME = get_home_dir();

unless(@ARGV ==3){
    die $usage;
}

my ($cnFile, $gmtFile, $expFile) =  @ARGV;

open(IN1, $cnFile) or die $usage;
chomp(my $tmp = <IN1>);
my $header = $tmp."\n";
my @sample1 = split("\t", $tmp);

open(IN2, $expFile) or die $usage;
chomp($tmp = <IN2>);
my @sample2 = split("\t", $tmp); 
my @sample = isect(\@sample1, \@sample2) or die $usage;

chomp(my @gmt = `cat $gmtFile`);

my $maxLogP = 20;

while(<IN1>){
    open(OUT , ">tmp${$}.cn.tab");
    print OUT $header;
    print OUT $_;
    close(OUT);
    chomp;
    my @tmp = split("\t");
    my $id = shift(@tmp);
    @tmp = grep {/^$id\t/} @gmt or next;
    @tmp = split("\t", $tmp[0]);
    my @gene = @tmp[2..$#tmp];
    map {s/^\[//g} @gene;
    map {s/\]$//g} @gene;
    my %gene;
    map {$gene{$_} = 1} @gene;
    open(IN2, $expFile) or die $usage;
    my $header2 = <IN2>;
    open(OUT, ">tmp${$}.exp.tab"); 
    print OUT $header2; 
    while(<IN2>){
	/^([^\t]+)\t/ or next;
	$gene{$1} or next;
	print OUT $_;
    }
    close(OUT);
    system("perl $HOME/perl/matrixCorrelation.pl tmp${$}.cn.tab tmp${$}.exp.tab  > tmp${$}.cor.txt");
    my %pvalue;
    open(IN2, "tmp${$}.cor.txt");
    while(<IN2>){
	chomp;
	my @tmp = split("\t");
	my $g = $tmp[1];
	my $p = ($tmp[3]==0)?$maxLogP:(-log($tmp[3])/log(10));
	if($tmp[2] != 1){
	    $p = 0;
	}
	$p < $pcutoff and next;
	$pvalue{$g} = $p;
    }
    close(IN2);
    @gene = sort {$pvalue{$b} <=> $pvalue{$a}} keys %pvalue;
    @gene or next;
    print join("\t", ($id, "",  map {$_."(".substr($pvalue{$_},0,4).")" } @gene ))."\n";
}

`rm tmp${$}.*`;

sub isect {
    my @a = @{shift(@_)};
    my @b = @{shift(@_)};
    my %union;
    my %isect;
    foreach my $e(@a,@b){$union{$e}++ && $isect{$e}++}
    return keys %isect;
}
