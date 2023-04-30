#!/usr/bin/perl
# Run on the output of checks.btred.

use warnings;
use strict;
use feature qw{ say };
use open IO => ':encoding(UTF-8)', ':std';

use Time::Piece;

my $timestamp = localtime->strftime('%Y-%m-%d');

while (<>) {
    chomp;
    my ($orig_type, $pos) = split /\t/;
    my $type = $orig_type;
    $type =~ s/ /_/g;
    $type =~ s/\W+/-/g;

    my $filename = "\L$type.fl";
    my $is_first = ! -e $filename;
    open my $out, '>>', $filename or die $!;
    say {$out} "$timestamp $orig_type" if $is_first;

    $pos =~ s{^.*/(annotators/.../done/)}{$1};

    say {$out} $pos;
    print {*STDERR} $., "\r";
}
