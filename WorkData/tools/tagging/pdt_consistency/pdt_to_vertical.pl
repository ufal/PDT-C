#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);


use Treex::PML;

Treex::PML::AddResourcePath('../../../../OriginalInputData/PDT/resources');

foreach my $dataset ('train', 'dtest', 'etest') {
  open (my $out, ">", "pdt.$dataset") or die "Cannot open file pdt.$dataset: $!";

  foreach my $f (glob("../../../../OriginalInputData/PDT/data/*mw/$dataset*/*.m")) {
    my $d = Treex::PML::Factory->createDocumentFromFile($f);

    for (my $t = 0; $t <= $d->lastTreeNo; $t++) {
      my ($nodes, $current) = $d->nodes($t);
      my $sum = 0;
      foreach my $n (@{$nodes}) {
        next unless $sum++;
        printf $out "%s\t%s\t%s\n", $n->attr('form'), $n->attr('lemma'), $n->attr('tag');
      }
      print $out "\n";
    }
  }

  close $out;
}
