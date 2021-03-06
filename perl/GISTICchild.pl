#!/usr/local/bin/perl 

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $usage = "usage: $0  [-v geneme_version (default: hg18) -o output_dir -a amp_cutoff -d del_cutoff -c conf_level -m marker_file] segfile \n";

my $amp = 0.1;
my $del = 0.1;
#my $conf = 0.75;
my $conf = 0.99;
my $markerfile = "";
my $outdir = "";
my $version = "hg18";
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
if($argv =~ s/-o\s+(\S+)//){
    $outdir = $1;
}
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);

my $segfile = shift or die $usage;
$outdir or $outdir = get_filename_without_suffix($segfile).".gistic";

if(-d $outdir){
    chomp(my $tmp = `ls $outdir  | wc`);
    $tmp =~ /^\s*(\d+)/;
    if($1 >  15){
	die "$outdir aleady exists!";
    }
}
`mkdir -p $outdir`;

my $thisdir = get_home_dir();

unless($markerfile){
    $markerfile = "$thisdir/data/SNP6probe.${version}.tsv";
    if(system("perl ${thisdir}/perl/getSegForGistic.pl $segfile $markerfile > tmp${$}.seg")){
	die;
    }
    $segfile = "tmp${$}.seg";
}

$ENV{mcr_root} =  "${thisdir}/gistic/MATLAB_Component_Runtime";
$ENV{LD_LIBRARY_PATH} =  $ENV{mcr_root}."/v714/runtime/glnxa64:".$ENV{LD_LIBRARY_PATH};
$ENV{LD_LIBRARY_PATH} =  $ENV{mcr_root}."/v714/sys/os/glnxa64:".$ENV{LD_LIBRARY_PATH};
$ENV{LD_LIBRARY_PATH} =  $ENV{mcr_root}."/v714/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:".$ENV{LD_LIBRARY_PATH};
$ENV{LD_LIBRARY_PATH} =  $ENV{mcr_root}."/v714/sys/java/jre/glnxa64/jre/lib/amd64/server:".$ENV{LD_LIBRARY_PATH};
$ENV{LD_LIBRARY_PATH} =  $ENV{mcr_root}."/v714/sys/java/jre/glnxa64/jre/lib/amd64:".$ENV{LD_LIBRARY_PATH};
$ENV{XAPPLRESDIR} =  $ENV{mcr_root}."/v714/X11/app-defaults";

my $refgenefile = "$thisdir/gistic/refgenefiles/${version}.mat";


#my $command = "$thisdir/gistic/gp_gistic2_from_seg -b $outdir -seg $segfile -mk $markerfile -refgene $refgenefile -genegistic 1 -smallmem 1 -broad 1 -brlen 0.98 -conf $conf -ta $amp -td $del  ";

my $command = "$thisdir/gistic/gp_gistic2_from_seg -b $outdir -seg $segfile -mk $markerfile -refgene $refgenefile -genegistic 1 -smallmem 1 -broad 1 -brlen 0.7 -conf $conf -ta $amp -td $del  -maxseg 2000 -rx 0 ";

if(system($command)){
    die;
}

if(-f  "tmp${$}.seg"){
    `rm tmp${$}.seg`;
}
