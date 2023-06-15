#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use XML::LibXML;

use constant PML => 'http://ufal.mff.cuni.cz/pdt/pml/';

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => PML);

my $count = 1;
for my $tfile (@ARGV) {
    my $changed = 0;
    print {*STDERR} $count++, "/", scalar @ARGV, " $tfile \r";
    my $dom = 'XML::LibXML'->load_xml(location => $tfile);
    my @roots = $xpc->findnodes('/pml:tdata/pml:trees/*', $dom);
    warn "\nNo roots" unless @roots;

    for my $root (@roots) {
        my @deepords = sort { $a->textContent <=> $b->textContent }
                       $xpc->findnodes('.//pml:deepord', $root);
        my @ords = map $_->textContent, @deepords;

        if ($ords[0] != 0) {
            warn "\nInsert zero";
            unshift @ords, 0;
            my $zero = $root->addNewChild(PML, 'deepord');
            $zero->addChild($dom->createTextNode('0'));
            $changed = 1;
        }

        if ($ords[-1] != $#ords) {
            warn "\n", $root->{id}, ": @ords";
            for my $i (0 .. $#deepords) {
                $deepords[$i]->removeChildNodes;
                $deepords[$i]->addChild($dom->createTextNode($i));
            }
            $changed = 1;
        }
    }
    $dom->toFile($tfile) if $changed;
}

