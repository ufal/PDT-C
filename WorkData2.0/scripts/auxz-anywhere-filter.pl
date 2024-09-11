#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use utf8;

use open IO => ':encoding(UTF-8)', ':std';

use enum qw( TYPE FORM LEMMA TAG AFUN FUNCTOR POSITION );

my %by_short_lemma;
while (<>) {
    my @columns = split /\t/;
    my $short_lemma = $columns[LEMMA] =~ s/(?<=.)[-_`].*//r;

    # In the 1st phase, ignore lines witn "uninteresting" tags.
    next if $columns[TAG] =~ /^(?:[VNAPCQFBS]|Z:)/;

    ++$by_short_lemma{$short_lemma}{ $columns[AFUN] }
        { join ' ', @columns[TYPE, FORM, LEMMA, TAG, FUNCTOR] };
}

# In the 2nd phase, ignore specific short lemmata.
for my $short_lemma (qw( z více méně )) {
    delete $by_short_lemma{$short_lemma};
}

for my $short_lemma (sort keys %by_short_lemma) {
    say "Keeping $short_lemma ", scalar keys %{ $by_short_lemma{$short_lemma} };
}
