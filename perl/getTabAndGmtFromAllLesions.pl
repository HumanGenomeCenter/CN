#!/usr/bin/local/perl

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;

my $qcutoff = 0.25;
my $argv = join(" ", @ARGV);
if($argv =~ s/-q\s+([\d.]+)//){        
    $qcutoff = $1;                                                                                              
}   

@ARGV = split(" ", $argv);
@ARGV or die "usage: $0  [-q  qvalue_cutoff] gisticDir\n";
foreach my $dir (@ARGV){
    -d $dir or next;
    my $out = get_filename_without_suffix($dir);
    chomp(my $tmp = `ls $dir/*all_lesions.conf_*.txt`) or next;  
    open(IN, $tmp);
    chomp($tmp = <IN>);
    
    my @tmp = split("\t", $tmp);
    
    
    my %amp;
    my %del;

    open(OUT, ">$dir/amp.tab");
    open(OUT2, ">$dir/del.tab");
    
    print OUT join("\t", ("", @tmp[9..$#tmp]))."\n";
    print OUT2 join("\t", ("", @tmp[9..$#tmp]))."\n";
    
    while(<IN>){
	chomp;
	my @tmp = split("\t");
	if($tmp[0] =~ /log2 ratios/ or $tmp[0] =~ /CN values/  and $tmp[5] <= $qcutoff){
	    my $id = $tmp[2]; # wide peak coodinate
	    $id =~ /(chr\w+):(\d+)-(\d+)/ or next;
	    $id  = $1."_".$2."_".$3;
	    if($tmp[0] =~ /^Amp/){
		print OUT join("\t", ($id, @tmp[9..$#tmp]))."\n";
		$amp{$id} = 1;
	    }elsif($tmp[0] =~ /^Del/){
		print OUT2 join("\t", ($id, @tmp[9..$#tmp]))."\n";
		$del{$id} = 1;
	    }
	}
    }
    
    close(OUT);
    close(OUT2);
    

    my %ampGene;
    chomp($tmp = `ls $dir/*amp_genes.conf_*.txt`);
    open(IN,$tmp);
    <IN>;
    <IN>;
    <IN>;
    chomp($tmp = <IN>);
    my @id = split("\t", $tmp);
    shift(@id);
    @id = map {/(chr\w+):(\d+)-(\d+)/?$1."_".$2."_".$3:$_} @id;
    my @index = grep {$amp{$id[$_]}} (0..$#id);
    
    foreach(@id){
	$ampGene{$_} = [];
    }
    
    while(<IN>){
	chomp;
	my @tmp = split("\t");
	shift(@tmp);
	for(@index){
	    if($tmp[$_]){
		push(@{$ampGene{$id[$_]}}, $tmp[$_]); 
	    }
	}
    }
    
    
    my %delGene;
    chomp($tmp = `ls $dir/*del_genes.conf_*.txt`); 
    open(IN,$tmp);
    <IN>;
    <IN>;
    <IN>;
    chomp($tmp = <IN>);
    @id = split("\t", $tmp);
    shift(@id);
    @id = map {/(chr\w+):(\d+)-(\d+)/?$1."_".$2."_".$3:$_} @id;
    @index = grep {$del{$id[$_]}} (0..$#id);
    
    foreach(@id){
	$delGene{$_} = [];
    }
    
    while(<IN>){
	chomp;
	my @tmp = split("\t");
	shift(@tmp);
	for(@index){
	    if($tmp[$_]){
	    push(@{$delGene{$id[$_]}}, $tmp[$_]); 
	    }
	}
    }
    
    
    open(OUT, ">$dir/amp.gmt");
    open(OUT2, ">$dir/del.gmt");
    open(OUT3, ">$dir/amp.gene.txt");
    open(OUT4, ">$dir/del.gene.txt");
    
    
    foreach(sort_my_id(keys %ampGene)){
	my @tmp = @{$ampGene{$_}};
	map {s/^\[//g} @tmp;
	map {s/\]$//g} @tmp;
	if(@tmp){
	    print OUT join("\t", ($_, "", @tmp))."\n";
	    print OUT3 join("\n", (@tmp))."\n";
	}
    }

    foreach(sort_my_id(keys %delGene)){
	my @tmp = @{$delGene{$_}};
	map {s/^\[//g} @tmp;
	map {s/\]$//g} @tmp;
	if(@tmp){
	    print OUT2 join("\t", ($_, "", @tmp))."\n";
	    print OUT4 join("\n", (@tmp))."\n";
	}
    }
    
    close(OUT);
    close(OUT2);
}

sub sort_my_id{
    my %hash;
    foreach(@_){
        my($chr, $start, $end) = split("_",$_);
        defined($end) or $end = $start;
        $chr=~s/X/23/;
        $chr=~s/Y/24/;
        $chr =~s/chr//;
        $chr =~ /^\d+$/ or next;
        $hash{$chr}{$start}{$end} = $_;
    }
    my @tmp;
    foreach my $c ( sort {$a <=> $b } keys %hash) {
        foreach my $s ( sort {$a <=> $b} keys %{$hash{$c}}) {
            foreach my $e ( sort {$a <=> $b} keys %{$hash{$c}{$s}}) {
                push(@tmp,$hash{$c}{$s}{$e});
            }
        }
    }
    
    return @tmp;
}

