#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use open 'IO', ':encoding(:UTF-8)', ':std';
use Encode;

use Ufal::MorphoDiTa;
use XML::LibXML;
use Path::Tiny qw{ path };
use XML::XSH2 qw{ xsh };


package XML::XSH2::Map;
our ($PML_NS, $tag, $form_texts, $lemma, $file, $idx, $newfile);
package main;

# automatic_correction(tagger, form, lemma, tag) returns either
# ($NOT_NEEDED) -- the lemma+tag was found in the dictionary
# ($POSSIBLE, corrected_lemma, corrected_tag) -- unique automatic correction exists
# ($IMPOSSIBLE) -- either multiple or no possibilities
our ($NOT_NEEDED, $POSSIBLE, $IMPOSSIBLE) = (0, 1, 2);
sub automatic_correction {
  my ($tagger, $form, $lemma, $tag) = @_;

  my $dictionary = $tagger->getMorpho();
  my ($analyses, @lemmas, @tags) = (Ufal::MorphoDiTa::TaggedLemmas->new());
  if ($dictionary->analyze($form, $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $analyses) < 0) {
    return ($IMPOSSIBLE);
  }
  for (my ($i, $size) = (0, $analyses->size()); $i < $size; $i++) {
    my $lemma_tag = $analyses->get($i);
    push @lemmas, $lemma_tag->{lemma};
    push @tags, $lemma_tag->{tag};
  }

  # Full match?
  for (my $i = 0; $i < @lemmas; $i++) {
    if ($lemmas[$i] eq $lemma && $tags[$i] eq $tag) {
      return ($NOT_NEEDED);
    }
  }

  # Lemma change
  my @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $tags[$i] eq $tag && $dictionary->rawLemma($lemmas[$i]) eq $dictionary->rawLemma($lemma);
    push @match_indices, $i;
  }
  if (@match_indices == 1) {
    return ($POSSIBLE, $lemmas[$match_indices[0]], $tags[$match_indices[0]]);
  }

  # Tag change
  @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $lemmas[$i] eq $lemma && substr($tags[$i], 0, 1) eq substr($tag, 0, 1);
    push @match_indices, $i;
  }
  if (@match_indices == 1) {
    return ($POSSIBLE, $lemmas[$match_indices[0]], $tags[$match_indices[0]]);
  }

  return ($IMPOSSIBLE);
}

$PML_NS = 'http://ufal.mff.cuni.cz/pdt/pml/';

xsh q{
    register-namespace pml $PML_NS ;
    quiet ;
};

my $tagger_file = 'models/czech-morfflex-pdt-161209-devel.tagger';
my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
    or die "Cannot load tagger from file '$tagger_file'\n";

while (defined( $file  = shift )) {

    xsh << '__XSH__';
        $mdoc := open $file ;
        $form_texts = $mdoc//pml:form/text() ;
        $mnodes = $mdoc//pml:m ;
__XSH__

    my $forms    = 'Ufal::MorphoDiTa::Forms'->new;
    my $lemmas_t = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
    my $lemmas_a = 'Ufal::MorphoDiTa::TaggedLemmas'->new;

    for my $m (@$form_texts) {
        $forms->push("$m");
    }
    $tagger->tag($forms, $lemmas_t);

    my @results;

    for my $i (0 .. $forms->size - 1) {
        $results[$i] = { map +( $_ => $lemmas_t->get($i)->{$_} ),
                         qw{ tag lemma } };
        $results[$i]{form} = $forms->get($i);

        my $guesser_mode = $tagger->getMorpho->analyze(
            $forms->get($i), $Ufal::MorphoDiTa::Morpho::GUESSER, $lemmas_a
        );

        $results[$i]{was_guessed}
            = $guesser_mode == $Ufal::MorphoDiTa::Morpho::NO_GUESSER ? 0 : 1;

        $results[$i]{analyses} = [];
        for my $j (0 .. $lemmas_a->size - 1) {
             push @{ $results[$i]{analyses} }, {
                 map +( $_ => $lemmas_a->get($j)->{$_} ), qw{ tag lemma }
             };
        }
    }

    for my $i (0 .. $#results) {
        my $result = $results[$i];

        $idx = $i + 1;
        xsh << '__XSH__';
            my $tag = $mnodes[$idx]//pml:tag ;
            my $am := xinsert element pml:AM into $tag ;
            xmove $tag/text() into $am ;
            xinsert attribute
                concat("lemma=", $tag/preceding-sibling::pml:lemma/text())
                into $am ;
            set $am/@src 'orig' ;
            rm $tag/preceding-sibling::pml:lemma ;
__XSH__

        for my $analyses (@{ $result->{analyses} }) {
            $lemma = $analyses->{lemma};
            $tag = $analyses->{tag};
            xsh << '__XSH__';
                my $am := xinsert element pml:AM into $mnodes[$idx]/pml:tag ;
                xinsert attribute concat("lemma=", $lemma) into $am ;
                xinsert text $tag into $am ;
__XSH__
        }

        ($lemma, $tag) = @{ $result }{qw{ lemma tag }};
        xsh << '__XSH__';
            my $am := xinsert element pml:AM into $mnodes[$idx]/pml:tag ;
            xinsert attribute concat("lemma=", $lemma) into $am ;
            xinsert text $tag into $am ;
            set $am/@src 'tagger' ;
__XSH__

    }

    ( $newfile = $file ) =~ s=OriginalInputData/=WorkData/=;
    path($newfile =~ m=^(.*)/[^/]+$=)->mkpath;

    xsh << '__XSH__';
        xinsert text {"\n"} after //pml:AM ;
        save :f $newfile ;
__XSH__

}

__END__
schema:
       <member name="tag" required="1">
         <alt>
           <container>
             <cdata format="any"/>
             <attribute name="lemma" required="1">
               <cdata format="any"/>
             </attribute>
             <attribute name="src">
               <cdata format="any"/>
             </attribute>
           </container>
         </alt>
       </member>

data:
 <form>svìtlo</form>
 <tag>
   <AM lemma="svìtlo-1" src="orig">NNNS1-----A----</AM>
   <AM lemma="svìtlo-1">NNNS1-----A----</AM>
   <AM lemma="svìtlo-1">NNNS4-----A----</AM>
   <AM lemma="svìtlo-1">NNNS5-----A----</AM>
   <AM lemma="svìtlo-2">Db-------------</AM>
   <AM lemma="svìtlo-1" src="tagger">NNNS1-----A----</AM>
 </tag>

