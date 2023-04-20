#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use open IO => ':encoding(UTF-8)', ':std';

# Run on the output of deadj_subs.btred.

while (<>) {
    chomp;
    my ($lemma, $tag, $afun, $ptags, $pos) = split /\t/;
    my ($gender, $number, $case) = $tag =~ /^..(.)(.)(.)/;
    if ('Atr' eq $afun && $tag =~ /^A/ && $ptags =~ /(?:^|,)N/
        && $ptags =~ /(?:^|,)N..$number$case/
    ) {
        if ($ptags =~ /(?:^|,)..$gender/) {
            say "an3\t$_";
        } else {
            say "an2\t$_";
        }
    } elsif ('Atr' eq $afun && $tag =~ /^N/ && $ptags =~ /(?:^|,)N/
             && $ptags =~ /(?:^|,)N..$number$case/
    ) {
        if ($ptags =~ /(?:^|,)N.$gender/) {
            say "nn3\t$_";
        } else {
            say "nn2\t$_";
        }
    } elsif ($tag =~ /^N/) {
        say "nx\t$_";
    } elsif ($tag =~ /^A/) {
        say "ax\t$_";
    } else {
        say "xx\t$_";
    }
}
