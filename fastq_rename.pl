#!/usr/bin/perl

use strict;
use warnings;
#use Cwd;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IO::Compress::Gzip qw(gzip $GzipError);

##### ##### ##### ##### #####

use Getopt::Std;
use vars qw( $opt_a $opt_v);

# Usage
my $usage = "
fastq_rename.pl - manipulate the sequence identifier in a fastq file.
                      by
                Brian J. Knaus
                 October 2016

Copyright (c) 2016 Brian J. Knaus.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Usage: perl fastq_rename.pl options
 required:
  -a    fastq file.
 optional:
  -v    verbose mode [optional T/F, default is F].

";

# command line processing.
getopts('a:v:');
die $usage unless ($opt_a);

my ($inf, $verb);

$inf    = $opt_a if $opt_a;
$verb   = $opt_v ? $opt_v : "F";

##### ##### ##### ##### #####
# Globals.

my ($in, $outf, $out);
my (@temp, @temp2);


##### ##### ##### ##### #####
# Main.

# Manage outfile name.
$outf = outname($inf);

$in  = new IO::Uncompress::Gunzip $inf or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
$out = new IO::Compress::Gzip $outf or die "gzip failed: $GzipError\n";

while(<$in>){
  # Read in one record (four lines).
  chomp($temp[0] = $_);     # First line is id.
  chomp($temp[1] = <$in>);  # Second line is sequence.
  chomp($temp[2] = <$in>);  # Third line is id.
  chomp($temp[3] = <$in>);  # Fourth line is quality.
  
  # Manipulate the sequence identifier.
  @temp2 = split('_', $temp[0]);
  pop @temp2;
  $temp[0] = join('_', @temp2);
  
  # Write to file.
  print $out $temp[0]."\n";
  print $out $temp[1]."\n";
  print $out "+\n";
  print $out $temp[3]."\n";
}

close $in or die "$in: $GunzipError\n";
close $out or die "$out: $GzipError\n";


##### ##### ##### ##### #####
# Subroutines.

sub outname {
  my $inf = shift;
  my @temp = split("/", $inf);
  $inf = $temp[$#temp];
  @temp = split(/\./, $inf);
  my $outf = $temp[0];
  $outf = $outf."_rename.fastq.gz";

  return($outf);
}


##### ##### ##### ##### #####
# EOF.
