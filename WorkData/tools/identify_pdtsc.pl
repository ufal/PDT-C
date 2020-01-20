#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use utf8;

use FindBin;

use open IO => ':encoding(UTF-8)', ':std';
*STDERR->autoflush(1);

use constant {
    TOP => 10,
    PROGRESS => [qw[ | / - \ ]]
};

my $skip = qr/^(?:[,?"]|[avszi]|ale|byl(?:[aoyi])?|do|je|jsem|js[mt]e|na
              |s[ei]|ta[km]|to|už|že)$/xi;

my %match;

my $progress;
for my $file (glob "$FindBin::Bin/../../OriginalInputData/PDTSC/data/*.mdata") {
    open my $in, '<', $file or die $!;
    my %words;
    while (<$in>) {
        my $form;
        next unless ($form) = m{<form>(.*)</form>};
        next if $form =~ $skip;
        ++$words{$form};
    }
    my @top = (sort { $words{$b} <=> $words{$a} || $a cmp $b }
               keys %words)[0 .. TOP - 1];
    my $short = $file =~ s{.*/|\.mdata}{}gr;
    undef $match{"@top"}{$short};
    print STDERR PROGRESS->[++$progress % 4], "\r";
}

my %wdata;
for my $file (glob "$FindBin::Bin/../../OriginalInputData/PDTSC/data/*.w") {
    open my $in, '<', $file or die $!;
    my $short = $file =~ s{.*/|\.[0-9]{2}\.w}{}gr;
    while (<$in>) {
        my $form;
        next unless ($form) = m{<token>(.*)</token>};
        next if $form =~ $skip;
        ++$wdata{$short}{$form};
    }
    print STDERR PROGRESS->[--$progress % 4], "\r";
}
for my $doc (keys %wdata) {
    my @top = (sort { $wdata{$doc}{$b} <=> $wdata{$doc}{$a} || $a cmp $b }
               keys %{ $wdata{$doc} })[0 .. TOP - 1];
    if ($match{ "@top" }) {
        say $doc, "\t", join ' ', keys %{ $match{"@top"} };
    } else {
        warn "!! $doc";
    }
}
