#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use open IO => ':encoding(UTF-8)', ':std';

use POSIX qw( locale_h );
use locale;


my %by_lemma;
while (<>) {
    my ($form, $lemma) = split;
    ++$by_lemma{$lemma}{$form};
    ++$by_lemma{$lemma}{COUNT};
}
my $old_locale = setlocale(LC_COLLATE);
for my $lemma (
    sort { $by_lemma{$b}{COUNT} <=> $by_lemma{$a}{COUNT}
           || do {
               setlocale(LC_COLLATE, 'cs_CZ.UTF-8');
               my $r = $a cmp $b;
               setlocale(LC_COLLATE, $old_locale);
               $r }
    } keys %by_lemma
) {
    print "$lemma \[", delete $by_lemma{$lemma}{COUNT}, "] ";
    print "(", join ", ", sort {
        $by_lemma{$lemma}{$b} <=> $by_lemma{$lemma}{$a}
    } keys %{ $by_lemma{$lemma} };
    say ')';
}
