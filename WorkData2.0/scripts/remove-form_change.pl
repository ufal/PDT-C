#!/usr/bin/perl
use warnings;
use strict;

use XML::LibXML;

my $file = shift or die "Expected input: list of m-ids.\n";

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => 'http://ufal.mff.cuni.cz/pdt/pml/');

my %id;
open my $in, '<', $file or die "Cannout open $file: $!";
while (<$in>) {
    chomp;
    undef $id{$_};
}

for my $file (glob 'annotators/???/done/*.m') {
    my $dom = 'XML::LibXML'->load_xml(location => $file);
    my $changed;
    for my $m ($xpc->findnodes('//pml:m', $dom)) {
        if (exists $id{ $m->{id} }) {
            unless ($xpc->findvalue('pml:form_change', $m)) {
                warn "No form_change at $m->{id}.\n";
                next
            }
            $m->removeChild($xpc->findnodes('pml:form_change', $m));
            warn 'Removed ', $m->{id};
            $changed = 1;
        }
    }
    warn('Saved'), $dom->toFile($file) if $changed;
}
