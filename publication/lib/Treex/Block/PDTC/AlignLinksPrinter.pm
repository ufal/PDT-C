package Treex::Block::PDTC::AlignLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

has 'print_idx' => ( is => 'ro', isa => 'Bool', default => 0 );
has '_links' => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );

sub print_indexes {
    my ($self, $bundle) = @_;
    print join " ", map {($_->[0]->ord-1)."-".($_->[1]->ord-1).":".$_->[2]} sort {$a->[0]->ord <=> $b->[1]->ord} @{$self->_links};
    print "\n";
}

sub print_for_import {
    my ($self, $bundle) = @_;
    my $file_stem = $bundle->get_document->file_stem;
    my $links = $self->_links;
    foreach my $triple (@$links) {
        my ($from, $to, $type) = @$triple;
        print join "\t", ($file_stem, $from->id, $from->form, $to->id, $to->form, $type);
        print "\n";
    }
}

after 'process_bundle' => sub {
    my ($self, $bundle) = @_;
    if ($self->print_idx) {
        $self->print_indexes();
    }
    else {
        $self->print_for_import($bundle);
    }
    $self->_set_links([]);
};

sub process_anode {
    my ($self, $anode) = @_;
    my ($nodes, $types) = $anode->get_undirected_aligned_nodes();
    for (my $i = 0; $i < @$nodes; $i++) {
        push @{$self->_links}, [$anode, $nodes->[$i], $types->[$i]];
    }
}

1;
