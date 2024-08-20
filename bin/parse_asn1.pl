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

my $INPUT_FILE;
if (@ARGV) {
    $INPUT_FILE = $ARGV[0];
}

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
    my $out = "";
    my $src = "";

    if ($summary =~ /",$/) {
        $summary =~ s/",$//;
        if ($summary =~ /(.*)\[(.*)\]/) {
            my ($text, $comment) = ($1, $2);
            if ($text =~ / $/) {
                $text =~ s/ $//;
            }
            $out = "$text\n";
            $src = "$comment\n";
        } else {
            $out = "$summary\n";
        }
    } else {
        die $summary;
    }

    if ($INPUT_FILE) {
        open(OUT, ">${INPUT_FILE}.en") or die;
        print OUT $out;
        close(OUT);
        open(SRC, ">${INPUT_FILE}.src") or die;
        print SRC $src;
        close(SRC);
    } else {
        print $out;
        print STDERR $src;
    }
}
