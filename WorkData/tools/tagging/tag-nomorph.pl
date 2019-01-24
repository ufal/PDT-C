#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use open 'IO', ':encoding(:UTF-8)', ':std';

use FindBin;
use Ufal::MorphoDiTa;
use Treex::PML;

main(@ARGV);

sub main {
    my ($tagger_file, @files) = @_;
    my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
        or die "Cannot load tagger from file '$tagger_file'.\n";

    my $bindir = $FindBin::Bin;
    my @resource_paths = ("$bindir/../../../tred-extension/pdt_c_m/resources",
                          "$bindir/../../../OriginalInputData/PCEDT/resources");
    push @resource_paths, glob "$ENV{HOME}/.tred.d/extensions/*/resources";
    Treex::PML::SetResourcePaths(@resource_paths);

    for my $file (@files) {
        say STDERR $file;
        my $doc = 'Treex::PML::Factory'->createDocumentFromFile($file);
        for my $sentence ($doc->trees) {
            my @results;
            my $forms    = 'Ufal::MorphoDiTa::Forms'->new;
            my $lemmas_t = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
            my $lemmas_a = 'Ufal::MorphoDiTa::TaggedLemmas'->new;

            my @mforms = map $_->attr('form'), $sentence->children;
            $forms->push("$_") for @mforms;
            $tagger->tag($forms, $lemmas_t);

            my $node = $sentence;
            for my $i (0 .. $forms->size - 1) {
                $node = $node->following;
                my $tag = $lemmas_t->get($i)->{tag};
                my $lemma = $lemmas_t->get($i)->{lemma};

                $tagger->getMorpho->analyze(
                    $forms->get($i), $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $lemmas_a
                );

                $node->{tag} = 'Treex::PML::Factory'->createAlt;
                for my $j (0 .. $lemmas_a->size - 1) {
                    my $analysis = $lemmas_a->get($j);
                    my $is_recommended = $analysis->{tag} eq $tag
                                         && $analysis->{lemma} eq $lemma;
                    $node->attr('tag')->add(
                        'Treex::PML::Factory'->createContainer(
                            $analysis->{tag},
                            {lemma => $analysis->{lemma},
                             src   => 'auto',
                             (recommended => 1) x $is_recommended
                            }
                        )
                    );
                }
            }
        }
        $doc->save;
    }

}
