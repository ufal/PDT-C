package Treex::Block::PDTC::PrintForFastAlign;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Lexicon::CS;

extends 'Treex::Core::Block';

has 'print_lemmas' => ("is" => "ro", "default" => 0, "isa" => "Bool");

sub tokens_for_tree {
    my ($self, $bundle, $lang, $delete_traces) = @_;
    my $tree = $bundle->get_tree($lang, "a");
    my @all_nodes = $tree->get_descendants({ordered => 1});
    if ($delete_traces) {
        @all_nodes = grep {!defined $_->tag or $_->tag ne '-NONE-'} @all_nodes;
    }
    my $token_str = join " ", map {$self->print_lemmas ? Treex::Tool::Lexicon::CS::truncate_lemma($_->lemma, 1) : $_->form} @all_nodes;
    return $token_str;
}

sub process_bundle {
    my ($self, $bundle) = @_;
    my $en_token_str = $self->tokens_for_tree($bundle, "en", 1);
    my $cs_token_str = $self->tokens_for_tree($bundle, "cs");

    print join " ||| ", ($en_token_str, $cs_token_str);
    print "\n";
}

1;
