#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: cat gene_info | $PROGRAM taxid...
";

my %OPT;
getopts('', \%OPT);

if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my %TAXID;
for my $taxid (@ARGV) {
    $TAXID{$taxid} = 1;
}

my %COUNT;
while (<STDIN>) {
    chomp;
    if (/^#/) {
        print "$_\n";
        next;
    }
    my @f = split(/\t/, $_);
    my $taxid = $f[0];
    my $symbol = $f[2];
    my $descr = $f[8];
    my $type = $f[9];
    my $hgnc = $f[10];
    my $hgnc_descr = $f[11];
    my $status = $f[12];
    my $others = $f[13];
    if ($TAXID{$taxid}) {
        print "$_\n";
    }
}
