use warnings;
use strict;
use utf8;

use Ufal::MorphoDiTa;

package tagger;

sub new {
  my ($class, $model_path) = @_;

  my $self = {};
  bless $self, $class;
  $self->{tagger} = Ufal::MorphoDiTa::Tagger::load($model_path) or die "Cannot load tagger from file $model_path!";
  return $self;
}

sub tag {
  my ($self, @sentence) = @_;

  # Perform tagging
  my $forms = Ufal::MorphoDiTa::Forms->new();
  my $tagged_lemmas = Ufal::MorphoDiTa::TaggedLemmas->new();

  foreach my $word (@sentence) {
    $forms->push($word);
  }

  $self->{tagger}->tag($forms, $tagged_lemmas);

  my @result = ();
  for (my $i = 0; $i < @sentence; $i++) {
    push @result, {
      tag=>$tagged_lemmas->get($i)->{tag},
      lemma=>$tagged_lemmas->get($i)->{lemma}
    };
  }

  # Perform morphological analysis
  for (my $i = 0; $i < @sentence; $i++) {
    my $guesser_mode = $self->{tagger}->getMorpho()->analyze($sentence[$i], $Ufal::MorphoDiTa::Morpho::GUESSER, $tagged_lemmas);
    $result[$i]->{was_guessed} = $guesser_mode == $Ufal::MorphoDiTa::Morpho::NO_GUESSER ? 0 : 1;
    $result[$i]->{analyses} = [];
    for (my $j = 0; $j < $tagged_lemmas->size(); $j++) {
      push @{$result[$i]->{analyses}}, {
        tag=>$tagged_lemmas->get($j)->{tag},
        lemma=>$tagged_lemmas->get($j)->{lemma}
      };
    }
  }

  return @result;
}

1;
