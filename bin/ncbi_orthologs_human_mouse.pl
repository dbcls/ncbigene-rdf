#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM
";

my %OPT;
getopts('', \%OPT);

my @SPECIES = ("10090", "9606");

my %HASH = ();
for my $taxid (@SPECIES) {
    $HASH{$taxid} = 1;
}

while (<>) {
    chomp;
    my @f = split(/\t/, $_);
    my $tax1 = $f[0];
    my $gene1 = $f[1];
    my $tax2 = $f[3];
    my $gene2 = $f[4];
    if ($HASH{$tax1} && $HASH{$tax2}) {
        if ($tax1 eq "9606") {
            print "$gene1\t$gene2\n";
        } else {
            print "$gene2\t$gene1\n";
        }
    }
}
