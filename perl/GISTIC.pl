#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $usage = "usage: $0  [-v geneme_version (default: hg18) -a amp_cutoff -d del_cutoff -c conf_level -m marker_file] segfile \n";

my $amp = 0.1;
my $del = 0.1;
#my $conf = 0.75;
my $conf = 0.99;
my $version = "hg18";
my $markerfile = "";
my $argv = join(" ", @ARGV);
if($argv =~ s/-a\s+([\d.]+)//){
    $amp = $1;
}
if($argv =~ s/-d\s+([\d.]+)//){
    $del = $1;
}
if($argv =~ s/-c\s+([\d.]+)//){
    $conf = $1
}
if($argv =~ s/-m\s+(\S+)//){
    $markerfile  = $1;
}
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);
my $tmpFilePrefix = "tmp${$}"; 
chomp(my $pwd = `pwd`);

my $sgeMem = 32;
my $sgeMemArg = "";
if($sgeMem > 2){
    $sgeMemArg = "-l s_vmem=${sgeMem}G -l mem_req=${sgeMem}";
}

my @segfile = @ARGV or die $usage;

my $HOME =get_home_dir();
for my $seg (@segfile){
    my $seg2 = get_filename_without_suffix($seg);
    my $outdir = get_filename_without_suffix($seg).".gistic";
    if(-d $outdir){
	chomp(my $tmp = `ls $outdir  | wc`);
	$tmp =~ /^\s*(\d+)/;
	if($1 >  15){
	    warn "$outdir aleady exists!\n";
	    next;
	}
    }
    my $command = "perl $HOME/perl/GISTICchild.pl -v $version -a $amp -d $del -c $conf ".($markerfile?"-m $markerfile":"")." $seg";
    print_SGE_script("$command", "${tmpFilePrefix}.${seg2}.pl");
    while(system("qsub $sgeMemArg  -b y -cwd  -o /dev/null -e ${tmpFilePrefix}.${seg2}.err   $pwd/${tmpFilePrefix}.${seg2}.pl")!=0){
	sleep(10);
    }
}
wait_for_SGE_finishing("${tmpFilePrefix}");
#`rm -r ${tmpFilePrefix}.*`;
