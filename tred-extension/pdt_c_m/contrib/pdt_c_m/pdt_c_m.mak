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


sub bind_button {
    my ($button, $key, $dialog) = @_;
    $dialog->bind(all => $key, sub {
        $dialog->Walk(sub {
            my $widget = shift;
            $widget->invoke if 'Button' eq $widget->class
                            && $button eq $widget->cget('-text')
        })
    });
}

sub bind_dialog {
    my ($dialog) = @_;
    $dialog->bind(all => '<Tab>', sub { shift->focusNext });
    $dialog->bind(all => '<Shift-Tab>', sub { shift->focusPrev });
    bind_button(Cancel => '<Escape>', $dialog);
}

sub select_morph {
    my ($node) = @_;
    my $form = TredMacro::QueryString('Form:', 'Form:', $node->attr('form'));
    return unless defined $form;

    my $db = ToplevelFrame()->DialogBox(
        -title => 'Select lemma and tag',
        -buttons => ['OK', 'New', 'Cancel'],
    );
    bind_dialog($db);
    bind_button(New => '<Control-n>', $db);

    my @alt = AltV($node->attr('tag'));
    my @list = map tag2selection(), @alt;
    my $lb = $db->add(ScrlListbox =>
        -font => $font,
        -selectmode => 'browse',
        -width => -1,
        -height => (@list > 20 ? 20 : scalar @list),
        -scrollbars => 'oe',
        -listvariable => \ my $selected,
    )->pack(-fill => 'y');
    $lb->insert('end', @list);
    $lb->focus;
    $lb->activate(0);
    for my $i (0 .. $lb->size - 1) {
        if ($alt[$i]->get_attribute('recommended')) {
            $lb->itemconfigure($i, -foreground => 'red');
        } elsif ('orig' eq $alt[$i]->get_attribute('src')) {
            $lb->itemconfigure($i, -foreground => 'green');
        }
        if ($alt[$i]->get_attribute('selected')) {
            $lb->activate($i);
            $lb->itemconfigure($i, -background => 'yellow');
        }
    }
    $lb->see($lb->index('active'));

    my $answer = $db->Show;

    return $lb->curselection if 'OK' eq $answer;

    if ('New' eq $answer) {
        my ($result, $lemma, $tag) = new_lemma_tag($node, $form);
        if ('OK' eq $result) {
            AddToAlt($this, 'tag', Treex::PML::Container->new($tag, {
                lemma => $lemma, '#content' => $tag, src => 'manual'
            }, 1));
            $lb->insert(end => "$lemma  $tag");
            return [ $lb->size - 1 ]
        }
    }

    return
}

sub tag2selection { $_->get_attribute('lemma') . "  " . $_->value }

sub new_lemma_tag {
    my ($node, $form) = @_;
    my $dialog = ToplevelFrame()->DialogBox(
        -title => 'New lemma and tag',
        -buttons => [ 'OK', 'Cancel' ],
    );
    bind_dialog($dialog);
    $dialog->add(Label => -text => "New lemma and tag for $form")->pack;

    my $lf = $dialog->Frame->pack;
    $lf->Label(-text => 'Lemma')->pack(-side => 'left');
    my $le = $lf->Entry(-textvariable => \ (my $lemma = $form))
        ->pack(-side => 'right');
    $le->focus;
    $dialog->bind('<Alt-l>' => sub { $le->focus });

    my $tf = $dialog->Frame->pack;
    $tf->Label(-text => 'Tag')->pack(-side => 'left');
    my $te = $tf->Entry(-textvariable => \(my $tag = '-' x 15))
        ->pack(-side => 'right');
    $dialog->bind('<Alt-t>' => sub { $te->focus });

    return $dialog->Show, $lemma, $tag
}

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

