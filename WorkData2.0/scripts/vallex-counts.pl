#!/usr/bin/perl
use warnings;
use strict;

use XML::LibXML;

my %TREEBANK = (
    l => 'pdt',
    w => 'pcedt',
    p => 'pdtsc',
    m => 'pdt',
    c => 'pdt',
    f => 'faust',
);

my $vallex_file = shift;
die 'No vallex file found' unless -f $vallex_file;

my @data = glob 'annotators/???/done/*.t'
    or die 'No data found in annotators/???/done/*.t';

my %vcache;

my $vdom = 'XML::LibXML'->load_xml(location => $vallex_file);
for my $frame ($vdom->findnodes('/valency_lexicon/body/word/valency_frames/frame')) {
    delete @$frame{qw{
        hereditary_used pcedt_hereditary_used pdt_hereditary_used }};
    @$frame{qw{ Used pcedt_used pdt_used faust_used pdtsc_used }} = (0) x 5;
    my $id = $frame->{id};
    $vcache{$id} = $frame;
}

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => 'http://ufal.mff.cuni.cz/pdt/pml/');
for my $tfile (@data) {
    my $type = $TREEBANK{($tfile =~ m{.*/(.)})[0]};
    print STDERR $tfile, " $type\n";
    my $tdom = 'XML::LibXML'->load_xml(location => $tfile);
    for my $frame_rf ($xpc->findnodes('//pml:val_frame.rf', $tdom)) {
        my $ref = $frame_rf->textContent;
        $ref =~ s/^v#// or die "Unknown ref format: $ref";
        my $frame = $vcache{$ref};
        ++$frame->{Used};
        ++$frame->{"${type}_Used"};
    }
};
$vdom->toFile($vallex_file . '.cnt');

=head1 NAME

vallex-counts.pl

=head1 SYNOPSIS

cd dir-with-annotator-data
vallex-counts.pl path_to_vallex.xml

=head1 DESCRIPTION

Update the counts of frames used in the data. The new file is created
with a C<.cnt> extension.

=cut
