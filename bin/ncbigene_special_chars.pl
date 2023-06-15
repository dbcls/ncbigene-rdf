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

my @COUNT_DECIMAL;
my @COUNT_HYPHEN;
my @COUNT_OR;
my @COUNT_SEMICOLON;
my @COUNT_SINGLE_QUOTE;
my @COUNT_DOUBLE_QUOTE;
my @COUNT_QUOTE;
my @COUNT_BACKSLASH;
my @HEADER;
my $TOTAL = 0;
while (<>) {
    chomp;
    my @f = split(/\t/, $_, -1);
    if (@f != 16) {
        die;
    }
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
        if ($f[$i] =~ /^\d+$/) {
            $COUNT_DECIMAL[$i]++;
        }
        if ($f[$i] eq "-") {
            $COUNT_HYPHEN[$i]++;
        }
        if ($f[$i] =~ /\|/) {
            $COUNT_OR[$i]++;
        }
        if ($f[$i] =~ /;/) {
            $COUNT_SEMICOLON[$i]++;
        }
        if ($f[$i] =~ /'/) {
            $COUNT_SINGLE_QUOTE[$i]++;
        }
        if ($f[$i] =~ /"/) {
            $COUNT_DOUBLE_QUOTE[$i]++;
        }
        if ($f[$i] =~ /'/ && $f[$i] =~ /"/) {
            $COUNT_QUOTE[$i]++;
        }
        if ($f[$i] =~ /\\/) {
            $COUNT_BACKSLASH[$i]++;
        }
    }    
}
print "decimal\t-\t|\t;\t\\\t'\t\"\t\"'\tcount in each field\n";
for (my $i=0; $i<@HEADER; $i++) {
    my $count_decimal = $COUNT_DECIMAL[$i] || 0;
    my $count_hyphen = $COUNT_HYPHEN[$i] || 0;
    my $count_or = $COUNT_OR[$i] || 0;
    my $count_semicolon = $COUNT_SEMICOLON[$i] || 0;
    my $count_backslash = $COUNT_BACKSLASH[$i] || 0;
    my $count_single_quote = $COUNT_SINGLE_QUOTE[$i] || 0;
    my $count_double_quote = $COUNT_DOUBLE_QUOTE[$i] || 0;
    my $count_quote = $COUNT_QUOTE[$i] || 0;
    print "$count_decimal\t$count_hyphen\t$count_or\t$count_semicolon\t$count_backslash\t$count_single_quote\t$count_double_quote\t$count_quote\t[$i] $HEADER[$i]\n";
}
print "$TOTAL\t\t\t\t\t\t\t\tgenes in total\n";
