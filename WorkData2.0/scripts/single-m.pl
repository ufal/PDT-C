#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;
use XML::LibXML;

my $inpath  = "$FindBin::Bin/../../WorkData/PDTSC/data";
my $outpath = "$FindBin::Bin/../PDTSC/pml";

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => my $PML_NS = 'http://ufal.mff.cuni.cz/pdt/pml/');

for my $mfile (glob "$inpath/??_???.??.m") {
    say {*STDERR} $mfile;
    my $dom = 'XML::LibXML'->load_xml(location => $mfile);
    for my $mnode ($xpc->findnodes('//pml:m', $dom->documentElement)) {
        my ($tag, $lemma);
        if ($xpc->findnodes('pml:tag[@lemma]', $mnode)) {
            $tag = $xpc->findvalue('pml:tag/text()', $mnode);
            $lemma = $xpc->findvalue('pml:tag/@lemma', $mnode);
        } else {
            my $am = ($xpc->findnodes('pml:tag/pml:AM[@selected=1]',
                                      $mnode))[0];
            $am ||= ($xpc->findnodes('pml:tag/pml:AM[@recommended=1]',
                                     $mnode))[0];
            $lemma = $am->{lemma};
            $tag = $xpc->findvalue('text()', $am);
        }
        my $form = $xpc->findvalue('pml:form', $mnode);
        my $oldtag = ($xpc->findnodes('pml:tag', $mnode))[0];
        $mnode->removeChild($oldtag);

        $mnode->addNewChild($PML_NS, 'lemma')
            ->appendText($lemma);
        $mnode->appendText("\n");
        $mnode->addNewChild($PML_NS, 'tag')
            ->appendText($tag);
        $mnode->appendText("\n");
    }
    my ($basename) = $mfile =~ m{/([^/]+)$};
    $dom->toFile("$outpath/$basename", 1);
}
