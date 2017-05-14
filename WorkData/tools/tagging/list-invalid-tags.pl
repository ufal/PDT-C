#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use XML::LibXML;
use Encode;

binmode STDOUT, ':encoding(UTF-8)';

my $file = shift;
die "ERROR: Specify the file with valid tags as input.\n" unless -f $file;

open my $FH, '<', $file or die $!;

my %valid;
while (<$FH>) {
    chomp;
    undef $valid{$_};
}

for my $mw (glob 'WorkData/PDT/data/*/*/*.m') {

    print STDERR "$mw          \r";
    my $dom = 'XML::LibXML'->load_xml(location => $mw);

    my $xpc = 'XML::LibXML::XPathContext'->new($dom);
    $xpc->registerNs(pml => 'http://ufal.mff.cuni.cz/pdt/pml/');

    for my $tag (
        $xpc->findnodes('(//pml:tag/text() | //pml:tag/pml:AM/text())')
    ) {
        next unless 15 == length $tag && ! exists $valid{$tag};

        say $mw;
        say $xpc->findnodes('ancestor::pml:m', $tag)->[0]->toString, "\n";
    }
}
