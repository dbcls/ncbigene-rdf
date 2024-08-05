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

print '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .', "\n";
print '@prefix dct: <http://purl.org/dc/terms/> .', "\n";
print '@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .', "\n";
print '@prefix ncbigene: <http://identifiers.org/ncbigene/> .', "\n";
print '@prefix taxid: <http://identifiers.org/taxonomy/> .', "\n";
print '@prefix hgnc: <http://identifiers.org/hgnc/> .', "\n";
print '@prefix mim: <http://identifiers.org/mim/> .', "\n";
print '@prefix mirbase: <http://identifiers.org/mirbase/> .', "\n";
print '@prefix ensembl: <http://identifiers.org/ensembl/> .', "\n";
print '@prefix insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/> .', "\n";
print '@prefix : <https://dbcls.github.io/ncbigene-rdf/ontology.ttl#> .', "\n";

!@ARGV && -t and die $USAGE;

my $ID = "";
while (<>) {
    chomp;
    if (/^#/) {
        print STDERR "Skip $_\n";
        next;
    }

    my @field = split("\t");
    $ID = $field[1];
    my $label = quote_str($field[2]);

    print "\n";
    print "ncbigene:$field[1] a insdc:Gene ;\n";
    print "    dct:identifier \"$field[1]\" ;\n";
    print "    rdfs:label $label ;\n";
    if ($field[10] ne "-") {
        my $standard_name = quote_str($field[10]);
        print "    insdc:standard_name $standard_name ;\n";
    }
    if ($field[3] ne "-") {
        my $locus_tag = quote_str($field[3]);
        print "    insdc:locus_tag $locus_tag ;\n";
    }
    if ($field[4] ne "-") {
        my $synonyms = format_str_array($field[4]);
        print "    insdc:gene_synonym $synonyms ;\n";
    }
    if ($field[8] ne "-") {
        my $description = quote_str($field[8]);
        print "    dct:description $description ;\n";
    }
    if ($field[13] ne "-") {
        my $others = format_str_array($field[13], $field[8]); # exclude redundant description from other_designations
        if ($others) {
            print "    dct:alternative $others ;\n";
        }
    }
    if ($field[5] ne "-") {
        my $link = format_link($field[5]);
        if ($link) {
            print "    insdc:dblink $link ;\n";
        }
    }
    print "    :typeOfGene \"$field[9]\" ;\n";
    if ($field[12] eq "O") {
        print "    :nomenclatureStatus \"official\" ;\n";
    } elsif ($field[12] eq "I") {
        print "    :nomenclatureStatus \"interim\" ;\n";
    }
    if ($field[11] ne "-") {
        print "    :fullName \"$field[11]\" ;\n";
    }
    if ($field[5] ne "-") {
        my $db_xref = filter_str($field[5]);
        if ($db_xref) {
            print "    insdc:db_xref $db_xref ;\n";
        }
    }
    if ($field[15] ne "-") {
        my $feature_type = format_str_array($field[15]);
        print "    :featureType $feature_type ;\n";
    }
    print "    :taxid taxid:$field[0] ;\n";
    if ($field[6] ne "-") {
        print "    insdc:chromosome \"$field[6]\" ;\n";
    }
    if ($field[7] ne "-") {
        print "    insdc:map \"$field[7]\" ;\n";
    }
    my $date = format_date($field[14]);
    print "    dct:modified \"$date\"^^xsd:date .\n";
}

sub format_date {
    my ($date) = @_;
    if ($date =~ /^(\d\d\d\d)(\d\d)(\d\d)$/) {
        my ($y, $m, $d) = ($1, $2, $3);
        return "$y-$m-$d";
    }
}

sub format_str_array {
    my ($str, $exclude) = @_;
    my @arr = split(/\|/, $str);
    my @str_arr = ();
    for my $a (@arr) {
        if ($exclude && $a eq $exclude) {
            next;
        }
        push(@str_arr, quote_str($a));
    }
    if (@str_arr) {
        return join(" ,\n        ", @str_arr);
    }
}

sub format_link {
    my ($str) = @_;
    my @arr = split(/\|/, $str);
    my @link = ();
    for my $a (@arr) {
        if ($a =~ /^MIM:(\d+)$/) {
            push(@link, "mim:$1");
        } elsif ($a =~ /^HGNC:HGNC:(\d+)$/) {
            push(@link, "hgnc:$1");
        } elsif ($a =~ /^Ensembl:(\w+)$/) {
            push(@link, "ensembl:$1");
        } elsif ($a =~ /^miRBase:(MI\d+)$/) {
            push(@link, "mirbase:$1");
        }
    }
    return join(" ,\n        ", @link);
}

sub filter_str {
    my ($str) = @_;
    my @arr = split(/\|/, $str);
    my @link = ();
    for my $a (@arr) {
        if ($a =~ /^MIM:(\d+)$/) {
        } elsif ($a =~ /^HGNC:HGNC:(\d+)$/) {
        } elsif ($a =~ /^Ensembl:(\w+)$/) {
        } elsif ($a =~ /^miRBase:(MI\d+)$/) {
        } else {
            push(@link, quote_str($a));
        }
    }
    return join(" ,\n        ", @link);
}

sub quote_str {
    my ($str) = @_;

    if ($str =~ /\\/) {
        print STDERR "$ID $str";
        $str =~ s/\\/\\\\/g;
        print STDERR " => $str\n";
    }

    my $quoted;
    if ($str =~ /^"[^"]*"$/) {
        $quoted = $str;
        print STDERR "$ID $quoted\n";
    } elsif ($str =~ /"/ && $str =~ /'/ && $str !~ /"""/) {
        $quoted = '"""' . $str . '"""';
        print STDERR "$ID $quoted\n";
    } elsif ($str !~ /"/) {
        $quoted = '"' . $str . '"';
    } elsif ($str !~ /'/) {
        $quoted =  "'$str'";
        print STDERR "$ID $quoted\n";
    } else {
        die $str;
    }
    return $quoted;
}
