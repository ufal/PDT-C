#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;
use XML::LibXML;

my $path = "$FindBin::Bin/../../WorkData/";

open my $identify, '-|', "$path/tools/identify_pdtsc.pl"
    or die $!;

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => my $PML_NS = 'http://ufal.mff.cuni.cz/pdt/pml/');

while (<$identify>) {
    my ($m, $mdata) = split;
    my %morphology;
    for my $m_file (glob "$path/PDTSC/data/$m.??.m") {
        say STDERR $m_file;
        my $m_dom = 'XML::LibXML'->load_xml(location => $m_file);
        for my $m_node ($xpc->findnodes('//pml:m', $m_dom->documentElement)) {
            my ($tag, $lemma);
            if ($xpc->findnodes('pml:tag[@lemma]', $m_node)) {
                $tag = $xpc->findvalue('pml:tag/text()', $m_node);
                $lemma = $xpc->findvalue('pml:tag/@lemma', $m_node);
            } else {
                my $am = ($xpc->findnodes('pml:tag/pml:AM[@selected=1]',
                                         $m_node))[0];
                $am ||= ($xpc->findnodes('pml:tag/pml:AM[@recommended=1]',
                                        $m_node))[0];
                $lemma = $am->{lemma};
                $tag = $xpc->findvalue('text()', $am);
            }
            my $form = $xpc->findvalue('pml:form', $m_node);
            $morphology{ $m_node->{id} } = { tag   => $tag,
                                             lemma => $lemma,
                                             form  => $form};
        }
    }

    my $mdata_dom = 'XML::LibXML'->load_xml(
        location => "$path/PDTSC/data/$mdata.mdata");
    for my $m_node ($xpc->findnodes('//pml:m', $mdata_dom->documentElement)) {
        my $id = $m_node->{id};
        my $form = $xpc->findvalue('pml:form', $m_node);

        if ($xpc->findnodes('pml:tag', $m_node)) {
            my $tag = $xpc->findvalue('pml:tag', $m_node);
            my $lemma = $xpc->findvalue('pml:lemma', $m_node);
            $m_node->removeChild($_)
                for map $xpc->findnodes("pml:$_", $m_node),
                   qw( tag lemma );
        }

        $m_node->removeChild($xpc->findnodes('pml:form', $m_node));
        for my $tag (qw( lemma tag form )) {
            $m_node->addNewChild($PML_NS, $tag)
                   ->appendText($morphology{$id}{$tag});
            $m_node->appendText("\n");
        }

        warn("Missing $id.\n"), next unless delete $morphology{$id};

    }
    warn "Not matched $_\n" for keys %morphology;
    $mdata_dom->toFile("$path/../WorkData2.0/PDTSC/pml/$mdata.mdata.unf");
    0 == system("xmllint --format"
                . " $path/../WorkData2.0/PDTSC/pml/$mdata.mdata.unf"
                . " > $path/../WorkData2.0/PDTSC/pml/$mdata.mdata")
        or warn "Formatting failed for $mdata.\n";
    unlink "$path/../WorkData2.0/PDTSC/pml/$mdata.mdata.unf";
}
