#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use bignum;

# Format of the input files: tab separated.
# short_lemma afun lex/aux form lemma tag functor frequency

use enum qw( SHORT_LEMMA AFUN TYPE FORM LEMMA TAG FUNCTOR FREQ );

use open IO => ':encoding(UTF-8)', ':std';

use List::Util qw{ sum0 };

sub log2 ($x) { log($x) / log 2 }

sub entropy($type, @files) {
    die "Valid types: e|graph\n" unless $type =~ /^(?:e|graph)$/;

    my %e;
    process($files[$_], $_ + 1, \%e) for 0, 1;

    my %h;
    my %fy;
  FORM:
    for my $form (sort keys %e) {
        for my $version (1, 2) {
            my @f = @{ $e{$form}{E}{$version} // [] };
            my $sum = sum0(@f);

            warn("SKIPPING $form, not in $version"),
            delete $fy{$form},
            delete $h{$form},
            next FORM if 0 == $sum;

            $fy{$form}{$version} += $sum;

            my @p = map $_ / $sum, @f;
            my $h = -sum0(map $_ * log2($_), @p);
            $h{$form}{$version} = $h;
        }
    }
    for my $form (keys %h) {
        delete $h{$form} unless 2 == keys %{ $h{$form} };
    }

    if ('graph' eq $type) {
        for my $form (sort { $h{$a}{1} <=> $h{$b}{1}
                             || $h{$a}{2} <=> $h{$b}{2}
                      } keys %h
        ) {
            # say $form, "\t", $h{$form}{1}, ' ', $h{$form}{2};
            say $h{$form}{1}, ' ', $h{$form}{2};
        }
        exit
    }

    my %sum_y;
    for my $version (1, 2) {
        $sum_y{$version} = sum0(map $_->{$version}, values %fy);
    }
    my %py;
    for my $form (keys %h) {
        for my $version (1, 2) {
            $py{$form}{$version} = $fy{$form}{$version} / $sum_y{$version};
        }
    }

    my %pxy;
    for my $form (sort keys %e) {
        for my $version (1, 2) {
            for my $tuple (keys %{ $e{$form}{CE}{$version} }) {
                my $fxy = $e{$form}{CE}{$version}{$tuple};
                next unless $fy{$form}{$version};

                $pxy{$form}{$tuple}{$version} = ($py{$form}{$version} // 0) * $fxy / $fy{$form}{$version};
            }
        }
    }

    my %hyx;
    for my $form (keys %pxy) {
        for my $tuple (keys %{ $pxy{$form} }) {
            for my $version (1, 2) {
                next if 0 == ($pxy{$form}{$tuple}{$version} // 0)
                     && 0 == ($pxy{$form}{$tuple}{$version} // 0) / $py{$form}{$version};
                $hyx{$version} -= $pxy{$form}{$tuple}{$version}
                * log2($pxy{$form}{$tuple}{$version} / $py{$form}{$version});
            }
        }
    }
    for my $version (1, 2) {
        say $version, "\t", $hyx{$version};
    }
    say $hyx{1} - $hyx{2};
}

sub process($file, $version, $e) {
    open my $in, '<', $file or die "$file: $!";
    while (my $line = <$in>) {
        my @columns = split ' ', $line;
        my $lc_form = lc $columns[FORM];
        push @{ $e->{$lc_form}{E}{$version} }, $columns[FREQ];
        $e->{$lc_form}{CE}{$version}{"@columns[LEMMA, TAG, AFUN, FUNCTOR]"}
            += $columns[FREQ];
    }
}

if (3 != @ARGV) {
    die "Usage: $0 graph|e pdtc10.freq pdtc20.freq\n";
}
entropy(@ARGV);

=begin gnuplot

set key top left
plot 'file.dat' u 0:1 w points title '1.0', '' using 0:2 w points title '2.0'

=end gnuplot
