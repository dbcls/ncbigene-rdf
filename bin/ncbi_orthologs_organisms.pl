#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [ncbi_orthologs]
";

my %OPT;
getopts('', \%OPT);

my %HASH = ();
while (<>) {
    chomp;
    /^#/ and next;
    my @f = split(/\t/, $_);
    if (@f != 5) {
        die;
    }
    my $tax1 = $f[0];
    my $gene1 = $f[1];
    my $tax2 = $f[3];
    my $gene2 = $f[4];
    $HASH{$tax1}{$gene1} = 1;
    $HASH{$tax2}{$gene2} = 1;
}

my %COUNT = ();
for my $tax (sort {$a<=>$b} keys %HASH) {
    my @gene = keys %{$HASH{$tax}};
    my $n = @gene;
    $COUNT{$tax} = $n;
}

for my $tax (sort {$COUNT{$b}<=>$COUNT{$a}} keys %COUNT) {
    print "$tax\t$COUNT{$tax}\n";
}
