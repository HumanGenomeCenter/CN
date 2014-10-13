# !/usr/local/bin/perl 

use strict;
use warnings;


###home dir###
#my $HOME = $ENV{HOME}."/CN";
my $HOME = "/share2/home/niiyan/CN";


sub get_home_dir{
    return $HOME;
}

sub set_environment{
    my $isN =  ($ENV{HOSTNAME}=~/^n/)?1:0;
    chomp(my @lib = `ls  $HOME/java/lib`);
    my $javapath = "/usr/local/package/java/current6/bin";
    unless(grep {$_ eq $javapath} split(":", $ENV{PATH})){
        $ENV{PATH} = $javapath.":".$ENV{PATH};
    }
    my $rpath = $isN?"/usr/local/package/r/current/bin":"/usr/local/package/r/2.15.1_gcc/bin";
    unless(grep {$_ eq $rpath} split(":", $ENV{PATH})){
        $ENV{PATH} = $rpath.":".$ENV{PATH};
    }
    $ENV{CLASSPATH} = $HOME."/java/bin:$HOME/java/lib/".join(":".$HOME."/java/lib/",@lib);   
    $ENV{PERL5LIB} = $HOME."/perl";
    $ENV{R_LIBS} = $HOME."/R";
}

sub get_filename_without_suffix{
    if($_[0] =~ /^([^.\/]+)([^\/]*)$/){
        return $1;
    }elsif($_[0] =~ /((.*?\/)*([^.]+))/){
        return $3;
    }else{
        return;
    }
}


sub get_dir_and_filename_without_suffix{
    if($_[0] =~ /^([^.\/]+)([^\/]*)$/){
        return $1;
    }elsif($_[0] =~ /((.*?\/)*([^.]+))/){
        return $&;
    }else{
        return;
    }
}


sub print_SGE_script{
    my $command = shift;
    my $fh;
    my @env = grep {defined($ENV{$_})} qw(PATH PERL5LIB R_LIBS CLASSPATH LD_LIBRARY_PATH BOWTIE_INDEXES);
  my @out = (
      '#! /usr/local/bin/perl',
      '#$ -S /usr/local/bin/perl',
      #'#$ -v '.join (",",map {$_."=".$ENV{$_}} @env),
      );
    foreach(@env){
	push(@out , '$ENV{'.$_.'}="'.$ENV{$_}.'";');
    }
  push(@out, (
           'warn "command : '. $command.'\n";',
           'warn "started @ ".scalar(localtime)."\n";',
           "if(system (\"$command\" )){",
	   'die "failed @ ".scalar(localtime)."\n";',
	   "}else{",
           'warn "ended @ ".scalar(localtime)."\n";',
            "}"
       ));
  
    if(@_){
	open($fh, ">$_[0]");
	print $fh join("\n",@out)."\n";
	`chmod a+x $_[0]`;
    }else{
	print  join("\n",@out)."\n";
    }
}


sub  wait_for_SGE_finishing{
    my $script = shift;
    my $cutoff;
    if(@_){
	$cutoff = shift;
    }else{
	$cutoff = 1;
    }
    $script = substr($script,0,10);
    while(1){
	while(system("qstat > /dev/null") != 0){
	    sleep(10);
	}
	my $out = `qstat| grep $script | wc`;
	$out =~ /\d+/;
	if($& < $cutoff ){
	    return;
	}else{
	    sleep(10);
	}
    }
}

