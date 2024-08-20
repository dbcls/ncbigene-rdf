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

my $summary = "";
my $reading = 0;
while (<>) {
    chomp;
    if (/^  summary "(.*)/) {
        $summary = $1;
        $summary =~ s/^ //;
        $summary =~ s/ $//;
        if ($summary =~ /^ /) {
            print STDERR "$summary\n";
        }
        if ($summary =~ / $/) {
            print STDERR "$summary\n";
        }
        $reading = 1;
    } elsif (/^  \S+ {/) {
        $reading = 0;
    } elsif ($reading) {
        $summary .= $_;
    }
}

if ($summary) {
    if ($summary =~ /",$/) {
        $summary =~ s/",$//;
        if ($summary =~ /(.*)\[(.*)\]/) {
            my ($text, $comment) = ($1, $2);
            if ($text =~ / $/) {
                $text =~ s/ $//;
            }
            print "$text\n";
            print STDERR "$comment\n";
        } else {
            print "$summary\n";
        }
    } else {
        die $summary;
    }
}
