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

BEGIN { 'PML_M'->import }

my $STYLESHEET = 'PML_M_36';

sub detect {
    PML::SchemaDescription() =~ /PDT 3.6 morphological/
        && 'mdata' eq PML::SchemaName()
    ? 1 : 0
}


sub switch_context_hook {
    SetCurrentStylesheet($STYLESHEET);
    Redraw() if GUI();
}


#bind EditMorphology to m menu Edit Morphology
sub EditMorphology {
    ChangingFile(0);
    my $selected = select_morph($this);
    return unless $selected;
    warn "SEL: @$selected";
}

sub select_morph {
    my ($node) = @_;
    my $form = TredMacro::QueryString('Form:', 'Form:', $this->attr('form'));
    return unless defined $form;

    my @tags = grep ! defined $_->get_attribute('src'),
               AltV($this->attr('tag'));

    my ($orig_tag, $recommended_tag, $final_tag)
        = grep $_->get_attribute('src') =~ /orig|tagger|final/,
          AltV($this->attr('tag'));

    for my $tag ($orig_tag, $recommended_tag, $final_tag) {
        next unless defined $tag;

        unshift @tags, $tag
            unless any {
                $_->value eq $tag->value
                && $_->get_attribute('lemma') eq $tag->get_attribute('lemma')
            } @tags;
    }

    my $was_form_wrong = $form ne $this->attr('form');
    my @val = map tag2selection(), @tags;
    if ($was_form_wrong) {
        s/\\/\\\\/g, s/'/\\'/g for $form;
        @val = ();
    }

    my @sel = map tag2selection(), grep defined, $orig_tag, $recommended_tag, $final_tag;

    return TredMacro::ListQuery("Select lemma and tag for $form",
                                'browse',
                                \@val,
                                \@sel
    )
}

sub tag2selection { $_->get_attribute('lemma') . "  " . $_->value }

#include <contrib/support/unbind_edit.inc>

sub enable_edit_node_hook { 'stop' }

sub enable_attr_hook { 'stop' }

1;

=back

=cut

