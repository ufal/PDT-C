# -*- cperl -*-

=head1 pdt_c_m

Macros for annotation of the morphological layer of PDT-C.

=over 4

=cut

#include <contrib/pml/PML_M.mak>
#key-binding-adopt PML_M
#menu-binding-adopt PML_M

#encoding iso-8859-2


package pdt_c_m;
use strict;
use List::MoreUtils qw{ any };
use TrEd::Config qw( $font );

BEGIN { 'PML_M'->import }

my $STYLESHEET = 'PML_M_36';

sub detect {
    PML::SchemaDescription() =~ /PDT 3.6 morphological/
        && 'mdata' eq PML::SchemaName()
    ? 1 : 0
}


sub switch_context_hook {
    SetCurrentStylesheet($STYLESHEET);
    TrEd::MinorModes::enable_minor_mode($grp, 'Show_Neighboring_Sentences');
    Redraw() if GUI();
}


#bind EditMorphology to m menu Edit Morphology
sub EditMorphology {
    ChangingFile(0);
    my $selected = select_morph($this);
    return unless $selected;

    ChangingFile(1);
    delete $_->{selected} for @{ $this->attr('tag') };
    $this->attr('tag')->[ $selected->[0] ]{selected} = 1;
}

sub select_morph {
    my ($node) = @_;
    my $form = TredMacro::QueryString('Form:', 'Form:', $this->attr('form'));
    return unless defined $form;

    return TredMacro::ListQuery("Select lemma and tag for $form",
                                'browse',
                                [ map tag2selection(), AltV($this->attr('tag')) ],
    )
}

sub tag2selection { $_->get_attribute('lemma') . "  " . $_->value }


#bind NextUnknown to space menu Find Next Unknown
sub NextUnknown {
    ChangingFile(0);
    do {
        $this = $this->following;
        unless ($this) {
            TredMacro::NextTree() or return check_last();

            $this = $root;
        }
    } while $this && unambiguous_node();
    Redraw();
    EditMorphology() if $this->attr('tag')
                     && ! grep $_->get_attribute('selected'),
                          AltV($this->attr('tag'));
}


sub check_last {
    TredMacro::GotoTree(1);
    my $done = 1;
    { do {
        undef $done if $this->attr('tag')
                    && ! grep $_->get_attribute('selected'),
                         AltV($this->attr('tag'));
        $this = $this->following;
        unless ($this) {
            TredMacro::NextTree() or last;

            $this = $root;
        }
    } while $this; }
    $grp->toplevel->Dialog(-title   => 'End of file',
                           -text    => 'End of file reached. There are '
                                       . ($done ? 'no ' : q())
                                       . 'unfinished nodes.',
                           -font    => $font,
                           -bitmap  => $done ? 'info' : 'warning',
                           -buttons => [ 'OK' ]
                          )->Show;
}


#bind PrevUnknown to Shift+space menu Find Previous Unknown
sub PrevUnknown {
    ChangingFile(0);
    $this = $this->previous;
    while ($this->previous && unambiguous_node()) {
        $this = $this->previous;
        if ($this == $root) {
            TredMacro::PrevTree() or return;

            $this = $this->following while $this->following;
        }
    }
}


sub unambiguous_node {
    (! $this->attr('tag')
     || $this->attr('tag')->isa('Treex::PML::Container'))
}


#bind DeleteM to Delete menu Delete Analysis
sub DeleteM {
    ChangingFile(0);
    return if $this->attr('tag')->isa('Treex::PML::Container');
    for my $tag (AltV($this->attr('tag'))) {
        next unless $tag->{selected};
        delete $tag->{selected};
        ChangingFile(1);
    }
}


#include <contrib/support/unbind_edit.inc>

sub enable_edit_node_hook { 'stop' }

sub enable_attr_hook { 'stop' }

1;

=back

=cut

