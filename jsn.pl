#!/usr/bin/perl

use strict;
 
#-------------------- MODULES ---------------------
use Data::Dumper;	# stringified perl data structures
use JSON::XS;		# JSON serialising/deserialising
use XML::Writer;		# writing XML documents
use IO::File;		# supply object methods for filehandles
use Getopt::Std;		# GetOpts
use Getopt::Long;		# GetOpts
#-------------------- MODULES ---------------------

#-------------------- GLOBALS ---------------------
my $input="";		#
my $output="";		#
my $h="";		#
my $n=0;		# not to generate XML header
my $r='';		# name of the root element to wrap result
my $array_name="";	#
my $item_name="";	#
my $s=0;			# string transform
my $i=0;			# integer transform
my $l=0;			# literals transform
my $c=0;		# root array recovery
my $a=0;			#
my $t=0;			#
my $start=0;		#
#-------------------- GLOBALS ---------------------

#-------------------- ARGUMENTS ---------------------
main(@ARGV);

sub main 
{
  print "START\n";
  
  GetOptions(
    'input:s'		=> \$input,
    'output:s'		=> \$output,
    'h:s'		=> \$h,
    'n'			=> \$n,
    'r=s'		=> \$r,
    'array_name=s'	=> \$array_name,
    'item_name=s'	=> \$item_name,
    's'			=> \$s,
    'i'			=> \$i,
    'c'			=> \$c,
    'a'			=> \$a,
    't'			=> \$t,
    'start=i'		=> \$start,
);
  
  
  print "END\n";
}

#-------------------- ARGUMENTS ---------------------



#-------------------- HELP ---------------------
sub help {
    print "Usage: jsn.pl [OPTIONS]\n\n";
    print "options:\n";
    print "--input=filename\tInput JSON file.\n";
    print "--output=filename\tOutput XML file.\n";
    print "-h=subst\t\tReplacing substring for invalid input.\n";
    print "-n\t\t\tDo not generate XML header.\n";
    print "-r=root-element\tWTF?\n";
    print "--array-name=array-element\tRename array to array-element.\n";
    print "--item-name=item-element\tRename element name.\n";
    print "-s\t\t\tTransform\n";
    print "-i\t\t\tTransform\n";
    print "-l\t\t\tTransform\n";
    print "-c\t\t\tTransform\n";
    print "-a\t\t\tTransform\n";
    print "-t\t\t\tTransform\n";
    print "--start=n\t\tTransform\n";
}
#-------------------- HELP ---------------------