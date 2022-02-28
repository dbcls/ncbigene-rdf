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

print '@prefix : <http://purl.org/net/orthordf/hOP/ontology#> .', "\n";
print '@prefix ncbigene: <http://identifiers.org/ncbigene/> .', "\n";
print '@prefix obo: <http://purl.obolibrary.org/obo/> .', "\n";
print "\n";

my %GO = ();
my %TAX = ();
my %LABEL = ();
!@ARGV && -t and die $USAGE;
while (<>) {
    chomp;
    if (/^#/) {
        next;
    }
    my @f = split("\t", $_);
    if (@f != 8) {
        die;
    }
    my ($taxid, $geneid, $goid, $evidence, $qualifier, $go_term, $pubmed, $category) = @f;
    if ($evidence eq "ND") {
        # print STDERR $evidence, "\n";
        next;
    }
    if ($qualifier =~ /^NOT/) {
        # print STDERR $qualifier, "\n";
        next;
    }

    if ($goid =~ /^GO:\d{7}$/) {
        $goid =~ s/:/_/;
    } else {
        die;
    }
    if ($GO{$geneid}{$goid}{$evidence}{$qualifier}{$pubmed}) {
        die;
    } else {
        $GO{$geneid}{$goid}{$evidence}{$qualifier}{$pubmed} = $category;
    }
    if ($go_term) {
        if ($go_term =~ /"/) {
            die;
        }
    }
    if ($LABEL{$goid}) {
        if ($LABEL{$goid} ne $go_term) {
            die;
        }
    }
    $LABEL{$goid} = $go_term;
    $TAX{$geneid}{$taxid} = 1;
}

for my $geneid (sort {$a <=> $b} keys %GO) {
    my $taxid = get_taxid($geneid);
    my @goid = sort keys %{$GO{$geneid}};
    @goid = map { "obo:" . $_ } sort @goid;
    my $goids = join(", ", @goid);
    print "ncbigene:$geneid :hasGO $goids .\n";
    print "\n";
}

################################################################################
### Function ###################################################################
################################################################################
sub parse_qualifier {
    my ($qualifier) = @_;

    if ($qualifier =~ /^NOT (.+)/) {
        $qualifier = $1;
        return ":qualifierNOT :$qualifier";
    } elsif ($qualifier eq "-") {
        return ":qualifier :NA";
    } else {
        return ":qualifier :$qualifier";
    }
}

sub parse_pubmed {
    my ($pubmed) = @_;

    if ($pubmed eq "-") {
        return ":NA";
    }
    
    unless ($pubmed =~ /\d/) {
        die;
    }
    if ($pubmed =~ /[^\d\|]/) {
        die;
    }

    my @pubmed = split(/\|/, $pubmed);

    my @pmid = map { "pmid:" . $_ } @pubmed;
    my $pmids = join(", ", @pmid);

    return $pmids;
}

sub get_taxid {
    my ($geneid) = @_;

    my @taxid = keys %{$TAX{$geneid}};
    if (@taxid != 1) {
        die;
    }

    return "taxid:" . $taxid[0];
}
