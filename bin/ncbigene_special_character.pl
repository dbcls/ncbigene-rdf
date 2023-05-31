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

my @COUNT_HYPHEN;
my @COUNT;
my @COUNT_QUOTE;
my @COUNT_DOUBLEQUOTE;
my @COUNT_BACKSLASH;
my @HEADER;
my $TOTAL = 0;
while (<>) {
    chomp;
    my @f = split(/\t/, $_);
    if ($. == 1) {
        $f[0] =~ s/^#//;
        @HEADER = @f;
        next;
    }
    $TOTAL++;
    my $symbol = $f[2];
    my $descr = $f[8];
    my $hgnc = $f[10];
    my $hgnc_descr = $f[11];
    my $status = $f[12];
    my $others = $f[13];
    for (my $i=0; $i<@f; $i++) {
        if ($f[$i] eq "-") {
            $COUNT_HYPHEN[$i]++;
        }
        if ($f[$i] =~ /\|/) {
            $COUNT[$i]++;
        }
        if ($f[$i] =~ /'/) {
            $COUNT_QUOTE[$i]++;
        }
        if ($f[$i] =~ /"/) {
            $COUNT_DOUBLEQUOTE[$i]++;
        }
        if ($f[$i] =~ /\\/) {
            $COUNT_BACKSLASH[$i]++;
        }
    }    
}
print "-\t|\t'\t\"\t\\\n";
for (my $i=0; $i<@HEADER; $i++) {
    my $count_hyphen = $COUNT_HYPHEN[$i] || 0;
    my $count = $COUNT[$i] || 0;
    my $count_quote = $COUNT_QUOTE[$i] || 0;
    my $count_doublequote = $COUNT_DOUBLEQUOTE[$i] || 0;
    my $count_backslash = $COUNT_BACKSLASH[$i] || 0;
    print "$count_hyphen\t$count\t$count_quote\t$count_doublequote\t$count_backslash\t[$i] $HEADER[$i]\n";
}
print "$TOTAL\n";
