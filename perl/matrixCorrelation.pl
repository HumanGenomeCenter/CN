#!/usr/localbin/perl 
#$ -S /usr/local/bin/perl
use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);
require CN;
set_environment();

my $command =  "java utility.MatrixCorrelation2 ";
exit(system($command.join(" ", @ARGV)));
