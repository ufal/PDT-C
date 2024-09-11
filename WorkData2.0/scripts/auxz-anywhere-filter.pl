#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use utf8;

use open IO => ':encoding(UTF-8)', ':std';

use enum qw( TYPE FORM LEMMA TAG AFUN FUNCTOR POSITION );

my ($file1, $file2) = @ARGV;

my %by_lc_form;
while (<>) {
    my @columns = split /\t/;
    my $lc_form = lc $columns[FORM];

    ++$by_lc_form{$lc_form}{ $columns[AFUN] }{$ARGV}
        { join ' ', @columns[TYPE, FORM, LEMMA, TAG, FUNCTOR] };
}

# In the 2nd phase, ignore fomrs that were never AuxZ.
for my $lc_form (keys %by_lc_form) {
    delete $by_lc_form{$lc_form} if ! exists $by_lc_form{$lc_form}{AuxZ};
}

for my $file ($file1, $file2) {
    say "$file\n", '-' x 70;
    for my $lc_form (sort keys %by_lc_form) {
        for my $afun (sort keys %{ $by_lc_form{$lc_form} }) {
            for my $rest (sort {
                $by_lc_form{$lc_form}{$afun}{$file}{$b}
                    <=> $by_lc_form{$lc_form}{$afun}{$file}{$a}
                } keys %{ $by_lc_form{$lc_form}{$afun}{$file} }
            ) {
                say join "\t", $lc_form, $afun, $rest,
                    $by_lc_form{$lc_form}{$afun}{$file}{$rest};
            }
        }
    }
}
