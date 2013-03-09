#!/usr/bin/perl

use strict;
 
#------------------- MODULES -------------------
use Getopt::Long;
use JSON::XS;
use XML::Writer;
use IO::File;
#------------------- MODULES -------------------

#------------------- GLOBALS -------------------
my $input="";		# input file
my $output="";		# output file
my $h="-";		# substr
my $n=0;			# xmlheader
my $r='';		# wrap result in
my $array_name="array";	# array name
my $item_name="item";	# item name
my $s=0;			# string transform
my $i=0;			# integer transform
my $l=0;			# literals transform
my $c=0;			# root array recovery
my $a=0;			# size
my $t=0;			# index
my $start=0;		# index from 
#------------------- GLOBALS -------------------

#-------------------- MAIN --------------------
parse_ops(@ARGV); 

  my $json;
  
  # we load json file into $json.   
  local $/=undef; 
  
  open FILE, "<", $input or my_die(50,"Cannot open file: ".$input);
  $json = JSON::XS->new->utf8(0)->decode(<FILE>);
  close FILE;
   
  # open output file and make XML writer.
  my $out = new IO::File(">$output");
  my $writer = new XML::Writer(OUTPUT => $out, UNSAFE => 1);
  
  
  #lets write header and root tag if set.
  if(!$n) # HEADER
    {$writer->xmlDecl("UTF-8")}
  
  if($r) # ROOT TAG START
    {$writer->startTag($r)}
  
  #recursive implementation.
  if (ref $json eq 'ARRAY') 
    {subarray($json);}
  else
    {subdata($json);}
  
  
  if($r) # ROOT TAG END
    {$writer->endTag($r)}

  $writer->end();
  $out->close();
#-------------------- MAIN --------------------

#------------------- MY_DIE --------------------
sub my_die
{
  my ($err, $msg) = @_;
  $! = $err;
  die $msg;
}
#------------------- MY_DIE --------------------

#------------------ SUBARRAY -------------------
sub subarray
{
  my ($js) = @_;
  $writer->startTag($array_name);
  # we found an array, so we need to analyze what is inside the array.
  foreach (@$js) 
  {
    my $row = $_;
    if (ref $row eq '' or ref $row eq 'JSON::XS::Boolean') 
    {
      # if its item, we write it.
      write_value($item_name, $row);
    }
    else
    {
      # if its an object or array, 
      # we place start and end tag, and we go deeper
      $writer->startTag($item_name);
      subdata($row);
      $writer->endTag($item_name);  
    }
  }
  
  $writer->endTag($array_name);   
}
#------------------ SUBARRAY -------------------

#------------------- SUBDATA -------------------
sub subdata
{
  my ($js) = @_;
  
  # lets read $first and $second from associative array.
  # if its value is array, we call subarray.
  # if its value is hash, we call subdata.
  # else we can safely write values.
  while(my ($first, $second) = each(%$js)) 
  { 
    if(ref $second eq 'ARRAY')
    {
      $writer->startTag($first);
      subarray($second);
      $writer->endTag($first);
    } 
    elsif(ref $second eq 'HASH')
    {
      $writer->startTag($first);
      subdata($second);
      $writer->endTag($first);
    }
    else 
    {
      write_value($first, $second);
    }
  }
}
#------------------- SUBDATA -------------------
#----------------- WRITE_VALUE ------------------
sub write_value
{
  my ($first, $second) = @_;
  
  # first at all, we check if $second is defined.
  if($second eq undef )
  {  # ----- NULL -----
    # if not, we write it depending on $l param.
    if($l)
    {
      $writer->startTag($first);
      $writer->emptyTag('null');
      $writer->endTag($first);
    }
    else
    {
      if($second)
	{$writer->emptyTag($first, 'value' => $second);}
      else
	{$writer->emptyTag($first, 'value' => 'null');}
    }
  }
  # now we check if $second is a bool value.
  elsif(ref $second eq 'JSON::XS::Boolean')
  {  # ----- BOOL -----
    # if yes, we write it depending on $l param.
    if($l)
    {
      $writer->startTag($first);
      
      if($second)
	{$writer->emptyTag('true');}
      else
	{$writer->emptyTag('false');}
	
      $writer->endTag($first);
    }
    else
    {
      if($second)
	{$writer->emptyTag($first, 'value' => 'true');}
      else
	{$writer->emptyTag($first, 'value' => 'false');}
    }
  }
  #else it must be number, or string.
  else
  {
    # so we check if it is a number.
    if($second  =~ /^[+-]?\d+\.?\d*$/) # is a number?
    {  # ----- NUMBER -----
      # if the number is lesser then 0, we do this little magic.
      if($second < 0)
	{$second = $second - 1;}
      # now the int() will round as we need it.
      my $num = int($second);

      # now we cant write the number, depending on $i
      if($i)
	{$writer->emptyTag($first, 'value' => $num);}
      else
      {
	$writer->startTag($first);
	$writer->characters($num);
	$writer->endTag($first);
      }
    }
    else # ----- STRING -----
    {
      # there is no other options. We write string depending on $s
      if($s)
	{$writer->emptyTag($first, 'value' => $second);}
      else
      {
	$writer->startTag($first);
	$writer->characters($second);
	$writer->endTag($first);
      }
    }
  }
}
#----------------- WRITE_VALUE ------------------

#------------------ ARGUMENTS ------------------
sub parse_ops 
{
  my $pom = join(' ',@_);
  if ($pom eq "" || $pom =~ s/--help//)
  {
    help();
    exit 1;
  }
  
  GetOptions(
    'input:s'		=> \$input,
    'output:s'		=> \$output,
    'h:s'			=> \$h,
    'n'			=> \$n,
    'r:s'			=> \$r,
    'array_name:s'		=> \$array_name,
    'item_name:s'		=> \$item_name,
    's'			=> \$s,
    'i'			=> \$i,
    'c'			=> \$c,
    'a'			=> \$a,
    'array-size'		=> \$a,
    't'			=> \$t,
    'index-items'		=> \$t,
    'start:i'		=> \$start,
);
  
  if(!$input or !$output)
  {
    my_die(1,"input and output file must be specified!\n");
  }
  
  if(!$t and $start > 0)
  {
    my_die(1,"-t must be set if start is in use!\n");
  }
}
#------------------ ARGUMENTS ------------------

#-------------------- HELP --------------------
sub help {
    print "Usage: jsn.pl [OPTIONS]\n\n";
    print "options:\n";
    print "--help\t\t\t\tPrint this help.\n";
    print "--input=filename\t\tInput JSON file.\n";
    print "--output=filename\t\tOutput XML file.\n";
    print "-h=subst\t\t\tReplacing substring for invalid input.\n";
    print "-n\t\t\t\tDo not generate XML header.\n";
    print "-r=root-element\t\t\tName of pair element.\n";
    print "--array-name=array-element\tRename array to array-element.\n";
    print "--item-name=item-element\tRename element name.\n";
    print "-s\t\t\t\tTransform strings to elements.\n";
    print "-i\t\t\t\tTransform ints to elements.\n";
    print "-l\t\t\t\tTransform bools to elements.\n";
    print "-c\t\t\t\tConvert \< \> \& \n";
    print "-a, --array-size\t\tAdd size of array to each array element\n";
    print "-t, --index-items\t\tEach array item get index\n";
    print "--start=n\t\t\tIndex start from n\n";
}
#-------------------- HELP --------------------