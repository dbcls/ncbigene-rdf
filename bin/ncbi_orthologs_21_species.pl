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

my @SPECIES = ("10090", "10116", "28985", "318829", "33169", "3702", "4530", "4896", "4932", "5141",
               "6239", "7165", "7227", "7955", "8364", "9031", "9544", "9598", "9606", "9615", "9913");

my %HASH = ();
for my $taxid (@SPECIES) {
    $HASH{$taxid} = 1;
}

while (<>) {
    chomp;
    if ($. == 1) {
        print $_, "\n";
        next;
    }
    my @f = split(/\t/, $_);
    my $tax1 = $f[0];
    my $tax2 = $f[3];
    if ($HASH{$tax1} && $HASH{$tax2}) {
        print $_, "\n";
    }
}
