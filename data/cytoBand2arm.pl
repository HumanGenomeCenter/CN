#!/usr/bin/locus/perl 

use strict;
use warnings;
my ($c, $s, $e, $a);
while(<>){
    chomp;
    my @tmp = split("\t");
    $tmp[3] =~ /\w+[pq]/;
    if(!defined($a)){
	($c, $s, $e, $a) = ($tmp[0], $tmp[1], $tmp[2], $&);
    }elsif($a eq $&){
	$e = $tmp[2];
    }else{
	print join("\t", ($c, $s, $e, $a))."\n";
	($c, $s, $e, $a) = ($tmp[0], $tmp[1], $tmp[2], $&);
    }
}
print join("\t", ($c, $s, $e, $a))."\n"; 
