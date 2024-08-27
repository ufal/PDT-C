#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use Data::Dumper;
use List::Util qw{ sum0 };

sub main($first, $last) {
    my (%tag_afun_functor, %lemma_tag_afun_functor, %by_form);
    for my $file ($first, $last) {
        open my $in, '<', $file or die "$file: $!";

        while (<$in>) {
            chomp;
            my ($form, $lemma, $tag, $afun, $functor) = split /\t/;
            ++$tag_afun_functor{"$tag\t$afun\t$functor"}{$file};
            ++$lemma_tag_afun_functor{"$lemma\t$tag\t$afun\t$functor"}{$file};
            ++$by_form{$form}{$file}{taf}{"$tag\t$afun\t$functor"};
            ++$by_form{$form}{$file}{ltaf}{"$lemma\t$tag\t$afun\t$functor"};
        }
    }
    my $count = 0;
    my %type_diff = (taf => 0, ltaf => 0);
    for my $form (sort keys %by_form) {
        my %total;
        for my $file ($first, $last) {
            for my $detail (qw( taf ltaf )) {
                $total{$file}{$detail}
                    = sum0(values %{ $by_form{$form}{$file}{$detail} });
                $total{$file}{type}{$detail}
                    += keys %{ $by_form{$form}{$file}{$detail} };
            }
            if ($total{$file}{taf} != $total{$file}{ltaf}) {
                die Dumper $form, $file, $total{$file};
            }
            delete $total{$file}{ltaf};
            $total{$file}{count} = delete $total{$file}{taf};

        }
        $count += $total{$last}{count} - $total{$first}{count};

        for my $detail (qw( taf ltaf )) {
            if ($total{$first}{type}{$detail} != $total{$last}{type}{$detail}) {
                print Dumper $form, $detail, $by_form{$form}, $total{$last}{type}{$detail}
                            - $total{$first}{type}{$detail};;
                $type_diff{$detail} += $total{$last}{type}{$detail}
                                    - $total{$first}{type}{$detail};
            }
        }
    }
    say sprintf "Total count: %+d", $count;
    say sprintf "Type count taf: %+d", $type_diff{taf};
    say sprintf "Type count ltaf: %+d", $type_diff{ltaf};
}

main(@ARGV);
