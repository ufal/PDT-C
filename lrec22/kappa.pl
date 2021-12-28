#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use FindBin;
use List::Util qw{ sum };
use Math::BigFloat;

my $afun_count = 25;
my $tails = 3;
my $full_count = $afun_count * 2 ** $tails;

sub files_of_type ($file, $type) {
    open my $fh, '<', $file or die "$file: $!";
    my %files;
    while (<$fh>) {
        my ($name, $ftype) = (split "\t", $_, 5)[1, 3];
        next if $ftype ne $type && $name !~ /gold/;

        $name =~ s{.*/}{};
        ++$files{$name};
    }
    return sort keys %files
}

sub sentence_sizes ($lines) {
    my %size;
    for (@$lines) {
        my $root = (split "\t", $_, 4)[2];
        ++$size{$root};
    }
    my $sum = sum(values %size);
    my $sentence_tally = keys %size;
    my $sentence_length = 'Math::BigFloat'->new("$sum") / $sentence_tally;
    return $sentence_length, $sentence_tally
}

sub lines ($f, $filter) {
    my $regex = join '|', map quotemeta, @$filter;
    open my $fh, '<', $f or die "$f: $!";
    my @lines;
    while (<$fh>) {
        chomp;
        push @lines, $_ if (split "\t", $_, 3)[1] =~ /$regex/;
    }
    return \@lines
}

sub unlabelled_agreement ($lines1, $lines2) {
    my %parent_of;
    for (@$lines1) {
        my ($id, $parent) = (split "\t", $_, 6)[0, 4];
        $parent_of{$id} = $parent;
    }

    my $same;
    for (@$lines2) {
        my ($id, $parent) = (split "\t", $_, 6)[0, 4];
        ++$same if $parent_of{$id} eq $parent;
    }
    return $same
}

sub labelled_agreement ($lines1, $lines2) {
    my %parent_and_afun;
    for (@$lines1) {
        my ($id, $parent, $afun) = (split "\t", $_, 8)[0, 4, 6];
        $parent_and_afun{$id} = [$parent, $afun];
    }

    my $same;
    for (@$lines2) {
        my ($id, $parent, $afun) = (split "\t", $_, 8)[0, 4, 6];
        ++$same if $parent_and_afun{$id}[0] eq $parent
                && $parent_and_afun{$id}[1] eq $afun;
    }
    return $same
}

sub full_agreement ($lines1, $lines2) {
    my %parent_and_afun;
    for (@$lines1) {
        my ($id, $parent, $afun, $exd, $parenth, $member)
            = (split "\t", $_)[0, 4, 6 .. 9];
        $parent_and_afun{$id} = [$parent, "$afun $exd $parenth $member"];
    }

    my $same;
    for (@$lines2) {
        my ($id, $parent, $afun, $exd, $parenth, $member) =
            (split "\t", $_)[0, 4, 6 .. 9];
        ++$same if $parent_and_afun{$id}[0] eq $parent
                && $parent_and_afun{$id}[1] eq "$afun $exd $parenth $member";
    }
    return $same
}

sub intersection ($files1, $files2) {
    my %intersection;
    ++$intersection{$_} for @$files1, @$files2;
    delete $intersection{$_}
        for grep $intersection{$_} == 1, keys %intersection;
    return sort keys %intersection
}

my $cfg_file = "$FindBin::Bin/../annot-bookkeep/list.cfg";
open my $cfg, '<', $cfg_file or die "$cfg_file: $!";
my $dir;
while (<$cfg>) {
    $dir = $1 if /^svn\s*=\s*(.+)/;
}
die "No dir defined in $cfg_file" unless defined $dir;
die "$dir not found" unless -d $dir;

$dir .= '/lrec';
die "$dir not found" unless -d $dir;

for my $type ('MST parser output',
              'No rules, MST parser output',
              'No rules, Not parsed',
              'Not parsed'
) {
    say $type;
    for my $f1 (glob "$dir/*.v") {
        for my $f2 (glob "$dir/*.v") {
            next if $f1 ge $f2;

            my @files1 = files_of_type($f1, $type);
            my @files2 = files_of_type($f2, $type);
            my @common = intersection(\@files1, \@files2);
            next unless @common;

            my $lines1 = lines($f1, \@common);
            my $lines2 = lines($f2, \@common);
            my $all = @$lines1;
            die "Different size $f1 $f2" unless $all == @$lines2;

            my ($size1, $sentence_tally1) = sentence_sizes($lines1);
            my ($size2, $sentence_tally2) = sentence_sizes($lines2);
            die "Size not same $f1 $f2" if $size1 != $size2
                                        || $sentence_tally1 != $sentence_tally2;

            my $same_edge = unlabelled_agreement($lines1, $lines2);
            my $se = 'Math::BigFloat'->new($same_edge);
            my $u_p_e = 'Math::BigFloat'->new(1) / $size1;
            my $u_p_0 = $se / $all;
            my $uas_kappa = 1 - (1 - $u_p_0) / (1 - $u_p_e);

            my $same_afun = labelled_agreement($lines1, $lines2);
            my $l_p_e = $sentence_tally1 / ($se * $afun_count);
            my $l_p_0 = 'Math::BigFloat'->new($same_afun) / $se;
            my $las_kappa = 1 - (1 - $l_p_0) / (1 - $l_p_e);

            my $same_full = full_agreement($lines1, $lines2);
            my $f_p_e = $sentence_tally1 / ($se * $full_count);
            my $f_p_0 = 'Math::BigFloat'->new($same_full) / $se;
            my $full_kappa = 1 - (1 - $f_p_0) / (1 - $f_p_e);

            say join "\t", "",
                     $f1 =~ m{/([^/]+)\.v},
                     $f2 =~ m{/([^/]+)\.v},
                     $uas_kappa,
                     $las_kappa,
                     $full_kappa;
        }
    }
}
