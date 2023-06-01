#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [gene_info]
";

my %OPT;
getopts('', \%OPT);

my %COUNT;
while (<>) {
    chomp;
    my @f = split(/\t/, $_);
    my $taxid = $f[0];
    my $symbol = $f[2];
    my $descr = $f[8];
    my $type = $f[9];
    my $hgnc = $f[10];
    my $hgnc_descr = $f[11];
    my $status = $f[12];
    my $others = $f[13];
    if ($taxid =~ /^\d+$/) {
        $COUNT{$taxid}++;
    }
}

for my $taxid (sort { $COUNT{$b} <=> $COUNT{$a} } keys %COUNT) {
    print "$taxid\t$COUNT{$taxid}\n";
}
