#!/usr/local/bin/perl

use strict;
use warnings;


`curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz" | gunzip -c > tmp${$}.bed`;

open(IN, "tmp${$}.bed");
while(<IN>){
    chomp;
    my @tmp = split("\t");
    $tmp[0] =~ /^chr(\w+)/;
    $tmp[3] = $1.$tmp[3];
    print join("\t", @tmp[0..3])."\n";
}
`rm tmp${$}.bed`;
