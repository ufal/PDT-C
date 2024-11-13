#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;
use List::Util qw{ uniq };
use XML::LibXML;

-d $ENV{UFAL_PDTC2A} or die '$UFAL_PDTC2A not set';

my $path = "$FindBin::Bin/../../WorkData2.0";

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => my $PML_NS = 'http://ufal.mff.cuni.cz/pdt/pml/');

my @mdata_files = uniq(
    map s{^.*/|\.[0-9]{2}\.m$}{}gr,
    glob "$ENV{UFAL_PDTC2A}/annotators/???/done/pdtsc_*.??.m");
for my $mdata (@mdata_files) {
    my %morphology;
    for my $m_file (glob "$ENV{UFAL_PDTC2A}/annotators/???/done/$mdata.??.m") {
        say STDERR $m_file;
        my $m_dom = 'XML::LibXML'->load_xml(location => $m_file);
        for my $m_node ($xpc->findnodes('//pml:m', $m_dom->documentElement)) {
            my ($tag, $lemma);
            if ($xpc->findnodes('pml:tag', $m_node)) {
                $tag = $xpc->findvalue('pml:tag/text()', $m_node);
                $lemma = $xpc->findvalue('pml:lemma/text()', $m_node);
            } else {
                die "Tag not found";
            }
            my $form = $xpc->findvalue('pml:form', $m_node);
            $morphology{ $m_node->{id} } = { tag   => $tag,
                                             lemma => $lemma,
                                             form  => $form};
        }
    }

    my $mdata_dom = 'XML::LibXML'->load_xml(
        location => "$path/PDTSC/pml/$mdata.mdata");
    for my $m_node ($xpc->findnodes('//pml:m', $mdata_dom->documentElement)) {
        my $id = $m_node->{id};
        my $form = $xpc->findvalue('pml:form', $m_node);

        if ($xpc->findnodes('pml:lemma', $m_node)) {
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
