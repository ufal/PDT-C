#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use Path::Tiny qw{ path };
use XML::LibXML;

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(p => 'http://ufal.mff.cuni.cz/pdt/pml/');

for my $tfile (@ARGV) {
    my $t_dom = 'XML::LibXML'->load_xml(location => $tfile);
    die "Not a t-file: $tfile\n"
        unless 'tdata' eq ($xpc->findnodes('/*', $t_dom))[0]->nodeName;
    my %arefs;
    @arefs{ map $_->textContent =~ s/.*#//r,
            $xpc->findnodes(join(' | ',
                                 '(//p:a/p:lex.rf',
                                 '//p:a/p:aux.rf/p:LM',
                                 '//p:a/p:aux.rf[not(p:LM)])'),
                    $t_dom)} = ();
    my $afile = $xpc->findvalue(
        '/p:tdata/p:head/p:references/p:reffile[@name="adata"]/@href', $t_dom);
    my $full_afile = path($tfile)->sibling($afile);
    my $a_dom = 'XML::LibXML'->load_xml(location => $full_afile);
    my %aids;
    @aids{ map $_->{id}, $xpc->findnodes(
        '(/p:adata/p:trees//p:LM[@id] | /p:adata/p:trees//p:children[@id] )',
        $a_dom)
    } = ();

    delete @arefs{ keys %aids };

    for my $aref (keys %arefs) {
        my @ttrees = $xpc->findnodes(
            "//p:a//*[substring-after(., '#') = '$aref']/ancestor::*[p:atree.rf]",
            $t_dom);
        say "$tfile##", 1 + $xpc->findvalue('count(preceding-sibling::*)', $_)
            for @ttrees;
    }
}
