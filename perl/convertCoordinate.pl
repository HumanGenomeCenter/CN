#!/usr/bin/perl

use strict;
use warnings;

$0 =~ /.*(\/){0,1}perl/ and push(@INC, $&);                                     
require LocusMapper;  

my $usage ="usage: $0 [-v geneme_version (default: hg18)]\n";
my $version = "hg18";
my $argv = join(" ", @ARGV);
if($argv =~ s/-v\s+(\S+)//){
    $version = $1;
}
@ARGV = split(" ", $argv);

setVersion($version);
readData();

print STDERR "enter input type [gene, coordinate, band or my_coordinate_id]: ";
chomp(my $input_type = <>);
if($input_type =~ /^g/i){
  print STDERR "enter gene symbol: ";
  chomp(my $gene = <>);
  print STDERR  "enter output type [coordinate,  my_coordinate_id  or band]: ";
  chomp(my $output_type = <>);
  if($output_type =~ /^c/i){
    print  join("\t", gene2coordinate($gene))."\n";
  }elsif($output_type =~ /^m/i){
      print join("_", gene2coordinate($gene))."\n"; 
  }elsif($output_type =~ /^b/i){
    print  join("\t", gene2band($gene))."\n";
  }

}elsif($input_type =~ /^c/i){
  print STDERR  "enter chromosome No: ";
  chomp(my $chr = <>);
  $chr =~ s/chr//;
  print STDERR  "enter start coordinate: ";
  chomp(my $start = <>);
  $start =  conv_si_prefix_to_number($start);
  print STDERR  "enter end coordinate: ";
  chomp(my $end = <>);
  $end =  conv_si_prefix_to_number($end);
  print STDERR  "enter output type [gene  or band]: ";
  chomp(my $output_type = <>);
  ($chr,$start,$end) = formatCoordinate($chr,$start,$end);
  if($output_type =~ /^g/i){
    print join("\n", coordinate2gene($chr,$start,$end))."\n";
  }elsif($output_type =~ /^b/i){
    print join("\t", coordinate2band($chr,$start,$end))."\n";
  }

}elsif($input_type =~ /^m/i){
  print STDERR  "enter my_coordinate_id: ";
  chomp(my $tmp = <>);
  my($chr, $start, $end) = formatCoordinate($tmp);
  $start =  conv_si_prefix_to_number($start);
  $end =  conv_si_prefix_to_number($end);
  print STDERR  "enter output type [gene  or band]: ";
  chomp(my $output_type = <>);
  if($output_type =~ /^g/i){
    print join("\n", coordinate2gene($chr,$start,$end))."\n";
  }elsif($output_type =~ /^b/i){
    print join("\t", coordinate2band($chr,$start,$end))."\n";
  }

}elsif($input_type =~ /^b/i){
  print STDERR  "enter band id: ";
  chomp(my $band = <>);
  print  STDERR "enter output type [gene,  coordinate  or  my_coordinate_id]: ";
  chomp(my $output_type = <>);
  if($output_type =~ /^g/i){
    print join("\n", band2gene($band))."\n";
  }elsif($output_type =~ /^c/i){
    print join("\t", band2coordinate($band))."\n";
  }elsif($output_type =~ /^m/i){
      print join("_", band2coordinate($band))."\n"; 
  }
}
