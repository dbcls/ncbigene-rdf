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

print '@prefix ncbigene: <http://identifiers.org/ncbigene/> .', "\n";
print '@prefix obo: <http://purl.obolibrary.org/obo/> .', "\n";
print '@prefix dct: <http://purl.org/dc/terms/> .', "\n";
print '@prefix pmid: <http://identifiers.org/pubmed/> .', "\n";
print '@prefix : <http://purl.org/orthordf/ontology#> .', "\n";
print "\n";

my %GO = ();

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
    if ($goid =~ /^GO:\d{7}$/) {
        $goid =~ s/:/_/;
    } else {
        die;
    }        
    $GO{$geneid}{$goid}{$evidence}{$qualifier}{$pubmed} = 1;
}

for my $geneid (sort {$a <=> $b} keys %GO) {
    my @goid = sort keys %{$GO{$geneid}};
    print "ncbigene:$geneid :hasGOannotation\n";
    my @annotation = ();
    for my $goid (@goid) {
        my @evidence = sort keys %{$GO{$geneid}{$goid}};
        for my $evidence (@evidence) {
            my @qualifier = sort keys %{$GO{$geneid}{$goid}{$evidence}};
            for my $qualifier (@qualifier) {
                my @pubmed = keys %{$GO{$geneid}{$goid}{$evidence}{$qualifier}};
                my $annotation = "";
                $annotation .= "    [\n";
                $annotation .= "        :hasGOterm obo:$goid ;\n";
                if (@pubmed) {
                    if (@pubmed == 1 && $pubmed[0] eq "-") {
                        # skip
                    } elsif (@pubmed >= 2) {
                        die;
                    } else {
                        @pubmed = map { "pmid:" . $_ } @pubmed;
                        $annotation .= "        dct:references @pubmed ;\n";
                    }
                } else {
                    die;
                }
                $annotation .= "        :qualifier :$qualifier ;\n";
                $annotation .= "        :evidenceCode :$evidence\n";
                $annotation .= "    ]";
                push @annotation, $annotation;
            }
        }
    }
    print join(",\n", @annotation), ";\n";
    @goid = map { "obo:" . $_ } sort @goid;
    my $goids = join(", ", @goid);
    print "    :gene2go $goids .\n";
    print "\n";
}
