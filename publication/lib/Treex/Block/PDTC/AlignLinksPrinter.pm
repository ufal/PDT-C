package Treex::Block::PDTC::AlignLinksPrinter;

use Moose;
use Treex::Core::Common;

extends 'Treex::Core::Block';

has 'print_idx' => ( is => 'ro', isa => 'Bool', default => 0 );
has '_links' => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has 'layer' => ( is => 'ro', isa => 'Str', default => 'a' );

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
        if ($from->get_layer eq "a" and $to->get_layer eq "a") {
            print join "\t", ($file_stem, $from->id, $from->form, $to->id, $to->form, $type);
        }
        else {
            print join "\t", ($file_stem, $from->id, $from->t_lemma, $to->id, $to->t_lemma, $type);
        }
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
    return if $self->layer !~ /a/;

    my ($nodes, $types) = $anode->get_undirected_aligned_nodes();
    for (my $i = 0; $i < @$nodes; $i++) {
        push @{$self->_links}, [$anode, $nodes->[$i], $types->[$i]];
    }
}

sub process_tnode {
    my ($self, $tnode) = @_;
    return if $self->layer !~ /t/;

    my ($nodes, $types) = $tnode->get_undirected_aligned_nodes();
    for (my $i = 0; $i < @$nodes; $i++) {
        push @{$self->_links}, [$tnode, $nodes->[$i], $types->[$i]];
    }
}

1;
