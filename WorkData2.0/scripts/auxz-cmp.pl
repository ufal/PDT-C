#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

die "$0 old.txt new.txt\n" unless 2 == @ARGV && 2 == grep -f $_, @ARGV;

my %seen;

my ($old, $new) = @ARGV;
open my $in1, '<', $old or die "$old: $!";
while (<$in1>) {
    my ($count, $form, $lemma) = split;
    my $simplified_lemma = $lemma =~ s/(?<=.)[-_`].*//r;
    $seen{$simplified_lemma}{old} += $count;
}

open my $in2, '<', $new or die "$new: $!";
while (<$in2>) {
    my ($count, $form, $lemma) = split;
    my $simplified_lemma = $lemma =~ s/(?<=.)[-_`].*//r;
    $seen{$simplified_lemma}{new} += $count;
}

for my $slemma (sort keys %seen) {
    next if exists $seen{$slemma}{new} && exists $seen{$slemma}{old};

    say $slemma, "\t",
        'Missing in ',
        exists $seen{$slemma}{new} ? 'old' : 'new';
}


=head1 DESCRIPTION

Compare the lists of AuxZ nodes in different versions of the treebanks.

=cut
