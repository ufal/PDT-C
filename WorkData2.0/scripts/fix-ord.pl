#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use XML::LibXML;

use constant PML => 'http://ufal.mff.cuni.cz/pdt/pml/';

my %ORD = (tdata => 'deepord',
           adata => 'ord');

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => PML);

my $count = 1;
for my $tfile (@ARGV) {
    my $changed = 0;
    print {*STDERR} $count++, "/", scalar @ARGV, " $tfile \r";
    my $dom = 'XML::LibXML'->load_xml(location => $tfile);
    my $doc_el = $dom->documentElement->nodeName;
    my @roots = $xpc->findnodes("/pml:$doc_el/pml:trees/*", $dom);
    warn "\nNo roots" unless @roots;

    for my $root (@roots) {
        my @sorted_ords = sort { $a->textContent <=> $b->textContent }
                          $xpc->findnodes(".//pml:$ORD{$doc_el}", $root);
        my @ords = map $_->textContent, @sorted_ords;

        if ($ords[0] != 0) {
            warn "\nInsert zero";
            unshift @ords, 0;
            my $zero = $root->addNewChild(PML, $ORD{$doc_el});
            $zero->addChild($dom->createTextNode('0'));
            $changed = 1;
        }

        if ($ords[-1] != $#ords) {
            warn "\n", $root->{id}, ": @ords";
            for my $i (0 .. $#sorted_ords) {
                $sorted_ords[$i]->removeChildNodes;
                $sorted_ords[$i]->addChild($dom->createTextNode($i));
            }
            $changed = 1;
        }
    }
    $dom->toFile($tfile) if $changed;
}

