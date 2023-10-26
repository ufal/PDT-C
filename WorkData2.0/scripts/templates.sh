#! /bin/bash
set -eu
export LC_ALL=C

scripts_dir=${0%/*}

function nsort() {
    sort | uniq -c | sort -n
}

if [[ ! -f templates.o ]] ; then
    time btred -qI "$scripts_dir"/templates.btred annotators/???/done/*.a > templates.o
fi

cut -f1,4 templates.o | nsort | grep -v '^ *1 ' > templates.no_afun
cut -f1,2,3,4 templates.o | nsort | grep -v '^ *1 ' | cut -f1,4 > templates.afuns
comm -3 <(sort templates.afuns) <(sort templates.no_afun) \
| sed 's/^[ \t]*[0-9]*//' \
| nsort \
| sed $'s/^[ \t]*[0-9]*  //' \
| cut -f1 \
| perl -E '
use warnings;
use strict;
my %lines;
while (<>) {
    chomp;
    undef $lines{$_};
}
open my $in, "<", "templates.o" or die $!;
while (<$in>) {
    chomp;
    my ($s) = /(.*?)\t/;
    say if exists $lines{$s};
}
' | sort -t$'\t' -k4,4rn -k1,1 -k3,3 \
| perl -E '
use warnings;
use strict;
my $previous = "";
while (<>) {
    my $phrase = (split /\t/, $_)[0];
    if ($phrase ne $previous) {
        say "\n$phrase";
        $previous = $phrase;
    }
    s/.*?\t//;
    s{\t[0-9]+\t/.*pdtc2a/}{\t};
    print;
}
'
rm templates.{no_afun,afuns}
