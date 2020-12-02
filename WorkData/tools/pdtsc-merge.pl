#!/usr/bin/perl

# Merges ids of m-nodes from *.m into *.mdata in PDTSC. Send output
# from identify_pdtsc.pl to STDIN.

use warnings;
use strict;
use feature qw{ say };
use open ':encoding(UTF-8)', ':std';


use FindBin;
use XML::LibXML;

use constant PML => 'http://ufal.mff.cuni.cz/pdt/pml/';

{   package Stream::M;
    use constant PML => 'http://ufal.mff.cuni.cz/pdt/pml/';
    sub new {
        my ($class, @files) = @_;
        my $xpc = 'XML::LibXML::XPathContext'->new;
        $xpc->registerNs(pml => PML);

        bless { files      => \@files,
                file_index => -1,
                xpc        => $xpc,
            }, $class
    }
    sub Next {
        my ($self) = @_;
        if (! $self->{xml}
            || $self->{node_index} >= $#{ $self->{xml} }
        ) {
            return if ++$self->{file_index} > $#{ $self->{files} };

            my $xml = 'XML::LibXML'->load_xml(
                location => $self->{files}[ $self->{file_index} ]);
            $self->{xml} = $self->{xpc}->find(
                '//pml:*[local-name() = "m" or local-name() = "s"]',
                $xml);
            $self->{node_index} = 0;

        } else {
            ++$self->{node_index};
        }
        return $self->{xml}[ $self->{node_index} ]
    }
}

sub check_forms {
    my ($xpc, $m_node, $mdata_node) = @_;
    my $m_form = $xpc->findvalue('pml:form', $m_node);
    my $mdata_form = $xpc->findvalue('pml:form', $mdata_node);
    $mdata_form =~ s/ //g;
    return $m_form eq $mdata_form
}

sub merge {
    my ($mdata, @m) = @_;
    my $xpc = 'XML::LibXML::XPathContext'->new;
        $xpc->registerNs(pml => PML);
    my $xml_mdata = 'XML::LibXML'->load_xml(location => $mdata);
    my $mdata_nodes = $xpc->findnodes(
        '//pml:*[local-name() = "m" or local-name() = "s"]', $xml_mdata);

    my $m_stream = 'Stream::M'->new(@m);
    for my $mdata_node (@$mdata_nodes) {
        ($mdata_node) = $xpc->findnodes('./pml:AM', $mdata_node)
            unless defined $mdata_node->{id};
        my $mdata_id = $mdata_node->{id};
        my $m_node = $m_stream->Next;
        my $m_id = $m_node->{id};

        die "Different form: $m_id, $mdata_id"
            unless check_forms($xpc, $m_node, $mdata_node);

        $mdata_node->{id} = $m_id;
    }
    open my $over, '>:raw', "$mdata.new" or die $!;
    $xml_mdata->toFH($over);
}


sub main {
    my $workdir = "$FindBin::Bin/../PDTSC/data";
    while (<>) {
        print;
        my ($m, $mdata) = split;
        $mdata = "$workdir/$mdata.mdata";
        my @m = glob "$workdir/$m*.m";
        merge($mdata, @m);
    }
}

main();
