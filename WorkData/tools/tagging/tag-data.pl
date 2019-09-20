#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use open 'IO', ':encoding(:UTF-8)', ':std';
use Encode;

use Ufal::MorphoDiTa;
use XML::LibXML;
use Path::Tiny qw{ path };
use FindBin;
use XML::XSH2 qw{ xsh };

use enum qw( NOT_NEEDED POSSIBLE IMPOSSIBLE );

package XML::XSH2::Map;
our ($PML_NS, $sentences, $tag, $form_texts, $lemma, $file, $idx, $newfile,
     $lemmas, $tags, $alemma, $atag, $unknown);
package main;

$PML_NS = 'http://ufal.mff.cuni.cz/pdt/pml/';

xsh q{
    register-namespace pml $PML_NS ;
    quiet ;
};

my $tagger_file = $FindBin::Bin . '/models/czech-morfflex-pdt-161209-devel.tagger';

my $method = shift;
my $run = { tag      => \&tag,
            check    => \&check,
            retag    => \&retag,
            fix_form => \&fix_form,
}->{$method};
die "Unknown method '$method', use 'tag', 'retag', 'fix_form', or 'check'.\n" unless $run;
$run->(@ARGV);


# automatic_correction(tagger, form, lemma, tag) returns either
# (NOT_NEEDED) -- the lemma+tag was found in the dictionary
# (POSSIBLE, corrected_lemma, corrected_tag)
#     -- unique automatic correction exists
# (IMPOSSIBLE) -- either multiple or no possibilities

sub automatic_correction {
    my ($tagger, $form, $lemma, $tag) = @_;

    my $dictionary = $tagger->getMorpho;
    my $analyses = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
    my (@lemmas, @tags);

    if ($dictionary->analyze(
        $form, $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $analyses
    ) < 0) {
        return IMPOSSIBLE
    }

    for (my ($i, $size) = (0, $analyses->size); $i < $size; $i++) {
        my $lemma_tag = $analyses->get($i);
        push @lemmas, $lemma_tag->{lemma};
        push @tags, $lemma_tag->{tag};
    }

    # Full match?
    for my $i (0 .. $#lemmas) {
        if ($lemmas[$i] eq $lemma && $tags[$i] eq $tag) {
            return NOT_NEEDED
        }
    }

    # Lemma change
    my @match_indices;
    for my $i (0 .. $#lemmas) {
        next unless $tags[$i] eq $tag
            && $dictionary->rawLemma($lemmas[$i])
               eq $dictionary->rawLemma($lemma);
        push @match_indices, $i;
    }
    if (@match_indices == 1) {
        return ( POSSIBLE,
                 $lemmas[ $match_indices[0] ],
                 $tags[ $match_indices[0] ])
    }

    # Tag change
    @match_indices = ();
    for my $i (0 .. $#lemmas) {
        next unless $lemmas[$i] eq $lemma
             && substr($tags[$i], 0, 1) eq substr($tag, 0, 1);
        push @match_indices, $i;
    }
    if (@match_indices == 1) {
        return ( POSSIBLE,
                 $lemmas[ $match_indices[0] ],
                 $tags[ $match_indices[0] ])
    }

    return IMPOSSIBLE
}

# Use for PDT:
# 1. keep golden analysis if present in the dictionary
# 2. replace lemma/tag if similar alternative exists
# 3. insert auto analyses if golden is too different
sub check {
    my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
        or die "Cannot load tagger from file '$tagger_file'\n";

    while (defined( $file  = shift )) {
        say STDERR $file;
        xsh << '__XSH__';
            $mdoc := open $file ;
            $sentences = $mdoc//pml:s ;
            $lemmas = $mdoc//pml:m/pml:lemma/text() ;
            $tags = $mdoc//pml:m/pml:tag/text() ;
__XSH__
        $idx = 0;
        for my $sentence (@$sentences) {

            my $sid = $sentence->{id};

            xsh('$form_texts = //pml:s[@id="' . $sid . '"]//pml:form/text()');
            for my $i (0 .. $#$form_texts) {
                (my $status, $alemma, $atag) = automatic_correction(
                    $tagger, "$form_texts->[$i]",
                    "$lemmas->[$idx]", "$tags->[$idx]"
                );

                xsh << '__XSH__';
                    $tag = $tags[1+$idx]/..;
                    my $am := xinsert element pml:AM into $tag ;
                    xmove $tag/text() into $am ;
                    set $am/@lemma string($tag/preceding-sibling::pml:lemma) ;
                    set $am/@src 'orig' ;
                    rm $tag/preceding-sibling::pml:lemma ;
__XSH__

                if (IMPOSSIBLE == $status) {
                    xsh << '__XSH__';
                        my $am := xinsert element pml:AM into $tag ;
                        set $am/text() '---------------' ;
                        set $am/@lemma '@unknown' ;
__XSH__

                } elsif (POSSIBLE == $status) {
                    xsh << '__XSH__';
                        rm $tag/pml:AM ;
                        my $am := xinsert element pml:AM into $tag ;
                        set $am/text() $atag ;
                        set $am/@lemma $alemma ;
                        set $am/@src 'auto' ;
                        set $am/@selected '1' ;
__XSH__

                } else {
                    xsh 'set $tag/pml:AM[1]/@selected "1"';
                }
            } continue {
                ++$idx;
            }

            xsh('$unknown = //pml:s[@id="' . $sid . '"]//@lemma[.="@unknown"]');
            if ($XML::XSH2::Map::unknown) {
                my $forms    = 'Ufal::MorphoDiTa::Forms'->new;
                my $analyses = 'Ufal::MorphoDiTa::Analyses'->new;
                my $lemma    = 'Ufal::MorphoDiTa::TaggedLemma'->new;
                my $lemmas   = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
                my $indices  = 'Ufal::MorphoDiTa::Indices'->new;

                xsh('$mnodes = //pml:s[@id="' . $sid . '"]/pml:m');
                for $XML::XSH2::Map::mnode (@$XML::XSH2::Map::mnodes) {
                    xsh(<< '__XSH__');
$am = $mnode/pml:tag/pml:AM ;
$form = $mnode/pml:form ;
$selected = $am/pml:tag/pml:AM[@selected="1"] ;
__XSH__

                    if ($XML::XSH2::Map::selected) {
                        $lemma->{lemma} = $XML::XSH2::Map::selected->{lemma};
                        $lemma->{tag} = $XML::XSH2::Map::selected->toString;
                        $lemmas->clear;
                        $lemmas->push($lemma);
                    } else {
                        $tagger->getMorpho->analyze("$XML::XSH2::Map::form",
                                                    !! $Ufal::MorphoDiTa::Morpho::GUESSER,
                                                    $lemmas);
                    }
                    $forms->push("$XML::XSH2::Map::form");
                    $analyses->push($lemmas);
                }
                $tagger->tagAnalyzed($forms, $analyses, $indices);
                for $XML::XSH2::Map::i (0 .. $forms->size - 1) {
                    my $i = $XML::XSH2::Map::i;
                    $XML::XSH2::Map::mnode = $XML::XSH2::Map::mnodes->[$i];
                    xsh('$unknown = $mnode/pml:tag/pml:AM[2]');
                    if ($XML::XSH2::Map::unknown) {
                        xsh('rm $unknown');
                        my $analysis = $analyses->get($i);
                        my $index    = $indices->get($i);
                        for my $j (0 .. $analysis->size - 1) {
                            ($XML::XSH2::Map::lemma, $XML::XSH2::Map::tag)
                                = @{ $analysis->get($j) }{qw{ lemma tag }};

                            # FIXME: Workaround morphodita returning empty lemma for "ama"
                            next unless length $XML::XSH2::Map::lemma;

                            xsh << '__XSH__';
                                $am := xinsert element pml:AM into $mnodes[$i+1]/pml:tag ;
                                set $am/@lemma $lemma ;
                                xinsert text $tag into $am ;
                                set $am/@src 'auto' ;
__XSH__
                            xsh('set $am/@recommended "1"') if $j == $index;
                        }
                    }
                }
            }
        }

        ( $newfile = $file ) =~ s=OriginalInputData/=WorkData/=;
        path($newfile =~ m=^(.*)/[^/]+$=)->mkpath;

        xsh << '__XSH__';
            set /pml:mdata/pml:head/pml:schema/@href "mdata_36_schema.xml" ;
            xinsert text {"\n"} after //pml:AM ;
            save :f $newfile ;
__XSH__
    }
}


# Post process: Reanalyse the sentences containing "New Form"
sub fix_form {
    my $xpc = 'XML::LibXML::XPathContext'->new;
    $xpc->registerNs(pml => $PML_NS);
    my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
        or die "Cannot load tagger from file '$tagger_file'\n";
    while (defined( $file  = shift )) {
        path($file)->slurp_utf8 =~ /New Form/ or next;

        say STDERR $file;
        xsh << '__XSH__';
            $mdoc := open $file ;
            $sentences = $mdoc//pml:s ;
__XSH__

        for my $sentence (@$sentences) {
            my $sid = $sentence->{id};
            xsh << "__XSH__";
                \$comments = \$mdoc//pml:s[\@id="$sid"]//\@type
                    [.="New Form"]/../pml:text ;
                for my \$comment in \$comments {
                    xinsert text \$comment replace
                        \$comment/ancestor::pml:m//pml:form/text() ;
                } ;
__XSH__

            next unless $XML::XSH2::Map::comments;

            my $forms    = 'Ufal::MorphoDiTa::Forms'->new;
            my $lemmas_t = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
            my $lemmas_a = 'Ufal::MorphoDiTa::TaggedLemmas'->new;

            xsh('$mnodes = //pml:s[@id="' . $sid . '"]//pml:m');
            xsh('$form_texts = //pml:s[@id="' . $sid . '"]//pml:form/text()');

            $forms->push("$_") for @$form_texts;
            $tagger->tag($forms, $lemmas_t);

            for my $i (0 .. $forms->size - 1) {

                my ($has_changed)
                    = $xpc->findvalue('.//@type', $XML::XSH2::Map::mnodes->[$i]);
                next unless $has_changed;

                my $result = { map +( $_ => $lemmas_t->get($i)->{$_} ),
                               qw{ tag lemma } };
                $result->{form} = $forms->get($i);

                $tagger->getMorpho->analyze(
                    $forms->get($i),
                    $Ufal::MorphoDiTa::Morpho::NO_GUESSER,
                    $lemmas_a
                );

                $result->{analyses} = [];
                for my $j (0 .. $lemmas_a->size - 1) {
                    push @{ $result->{analyses} }, {
                        map +( $_ => $lemmas_a->get($j)->{$_} ), qw{ tag lemma }
                    };
                }

                # my ($original_tag_element)
                #     = $xpc->findnodes('pml:tag', $XML::XSH2::Map::mnodes->[$i]);
                # my ($original_tag, $original_lemma);
                # if ($xpc->findvalue('pml:AM[2]', $original_tag_element)) {
                #     $original_tag
                #         = $xpc->findvalue('pml:AM[@selected=1]/text()',
                #                           $original_tag_element)

                #         || $xpc->findvalue('pml:AM[@recommended=1]/text()',
                #                           $original_tag_element);
                #     $original_lemma
                #         = $xpc->findvalue('pml:AM[@selected=1]/@lemma',
                #                           $original_tag_element)
                #         || $xpc->findvalue('pml:AM[@recommended=1]/@lemma',
                #                           $original_tag_element);
                # } else {
                #     $original_tag
                #         = $xpc->findvalue('text()', $original_tag_element);
                #     $original_lemma
                #         = $xpc->findvalue('@lemma', $original_tag_element);
                # }

                $idx = 1 + $i;
                xsh('delete $mnodes[$idx]/pml:tag/*');
                xsh('delete $mnodes[$idx]/pml:tag/@*');
                xsh('delete $mnodes[$idx]/pml:tag/text()');

                for my $analysis (@{ $result->{analyses} }) {
                    $lemma = $analysis->{lemma};
                    $tag = $analysis->{tag};
                    next if $lemma eq $result->{lemma}
                         && $tag eq $result->{tag};

                    xsh << '__XSH__';
                        my $am := xinsert element pml:AM
                            into $mnodes[$idx]/pml:tag ;
                        set $am/@lemma $lemma ;
                        set $am/@scr 'auto' ;
                        xinsert text $tag into $am ;
                        xinsert text {"\n"} before $am ;
__XSH__
                }

                ($lemma, $tag) = @{ $result }{qw{ lemma tag }};
                xsh << '__XSH__';
                    my $am := xinsert element pml:AM into $mnodes[$idx]/pml:tag ;
                    xinsert text $tag into $am ;
                    set $am/@lemma $lemma ;
                    set $am/@src 'auto' ;
                    set $am/@recommended 1 ;
                    xinsert text {"\n"} before $am ;
                    xinsert text {"\n"} after $am ;
__XSH__
            }
            xsh('for $comments delete ..');
        }
        xsh('save :b');
    }
}


# 17/04/29 Spec change: we only want non-guessed analyses.
sub retag {
    my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
        or die "Cannot load tagger from file '$tagger_file'\n";
    my $dictionary = $tagger->getMorpho;
    my $analyses = 'Ufal::MorphoDiTa::TaggedLemmas'->new;

    while (defined( $file = shift )) {
        say STDERR $file;

        xsh << '__XSH__';
            $mdoc := open $file ;
            $mnodes = //pml:m[pml:tag/pml:AM[@recommended]];
__XSH__

        next unless $XML::XSH2::Map::mnodes;

        for $XML::XSH2::Map::mnode (@$XML::XSH2::Map::mnodes) {
            xsh '$form = $mnode/pml:form';
            if ($dictionary->analyze(
                "$XML::XSH2::Map::form", $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $analyses
            ) < 0) { # Everything was guessed
                xsh 'delete $mnode/pml:tag/pml:AM[@src="auto"] ;
                     set $mnode/pml:tag/pml:AM/@selected 1 ;';

            } else {
                for (my ($i, $size) = (0, $analyses->size); $i < $size; $i++) {
                    ($alemma, $atag) = @{ $analyses->get($i) }{qw{ lemma tag }};
                    xsh << '__XSH__';
                        $tag = $mnode/pml:tag/pml:AM[@lemma=$alemma][.=$atag] ;
                        set $tag/@stay 1 ;
__XSH__
                }
                xsh << '__XSH__';
                    echo $mnode/@id count($mnode/pml:tag/pml:AM[@src="auto"][not(@stay)]) ;
                    rm $mnode/pml:tag/pml:AM[@src="auto"][not(@stay)] ;
                    rm $mnode/pml:tag/pml:AM/@stay ;
                    if 1=count($mnode/pml:tag/pml:AM) set $mnode/pml:tag/pml:AM/@selected 1 ;
__XSH__
            }
        }

        xsh 'save :b';
    }
}

sub tag {
    my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file)
        or die "Cannot load tagger from file '$tagger_file'\n";

    while (defined( $file  = shift )) {
        xsh << '__XSH__';
            $mdoc := open $file ;
            $sentences = $mdoc//pml:s ;
            $mnodes = $mdoc//pml:m ;
__XSH__

        my @results;

        for my $sentence (@$sentences) {

            my $sid = $sentence->{id};

            xsh('$form_texts = //pml:s[@id="' . $sid . '"]//pml:form/text()');

            my $forms    = 'Ufal::MorphoDiTa::Forms'->new;
            my $lemmas_t = 'Ufal::MorphoDiTa::TaggedLemmas'->new;
            my $lemmas_a = 'Ufal::MorphoDiTa::TaggedLemmas'->new;

            for my $m (@$form_texts) {
                $forms->push("$m");
            }
            $tagger->tag($forms, $lemmas_t);

            for my $i (0 .. $forms->size - 1) {
                push @results, { map +( $_ => $lemmas_t->get($i)->{$_} ),
                                 qw{ tag lemma } };
                $results[-1]{form} = $forms->get($i);

                my $guesser_mode = $tagger->getMorpho->analyze(
                    $forms->get($i), $Ufal::MorphoDiTa::Morpho::GUESSER, $lemmas_a
                );

                $results[-1]{was_guessed}
                    = $guesser_mode == $Ufal::MorphoDiTa::Morpho::NO_GUESSER
                    ? 0 : 1;

                $results[-1]{analyses} = [];
                for my $j (0 .. $lemmas_a->size - 1) {
                    push @{ $results[-1]{analyses} }, {
                        map +( $_ => $lemmas_a->get($j)->{$_} ), qw{ tag lemma }
                    };
                }
            }
        }

        for my $i (0 .. $#results) {
            my $result = $results[$i];

            $idx = $i + 1;
            xsh << '__XSH__';
                my $tag = $mnodes[$idx]//pml:tag ;
                my $am := xinsert element pml:AM into $tag ;
                xmove $tag/text() into $am ;
                set $am/@lemma $tag/preceding-sibling::pml:lemma/text()) ;
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
            set /pml:mdata/pml:head/pml:schema/@href "mdata_36_schema.xml" ;
            xinsert text {"\n"} after //pml:AM ;
            save :f $newfile ;
__XSH__

    }
}

__END__

 <form>svìtlo</form>
 <tag>
   <AM lemma="svìtlo-1" src="orig">NNNS1-----A----</AM>
   <AM lemma="svìtlo-1">NNNS1-----A----</AM>
   <AM lemma="svìtlo-1">NNNS4-----A----</AM>
   <AM lemma="svìtlo-1">NNNS5-----A----</AM>
   <AM lemma="svìtlo-2">Db-------------</AM>
   <AM lemma="svìtlo-1" src="tagger">NNNS1-----A----</AM>
   <AM lemma="svìtlo-1" src="final">NNNS1-----A----</AM>
 </tag>

<m id="m-cmpr9410-001-p24s3w4">
<src.rf>manual</src.rf>
<w.rf>
<LM>w#w-cmpr9410-001-p24s3w4</LM>
</w.rf>
<form>pøesto</form>
<tag><AM lemma="pøesto" src="orig">Dg-------1A----</AM>
<AM lemma="pøesto-1" src="auto" recommended="1">Db-------------</AM>
<AM lemma="pøesto-2" src="auto">J^-------------</AM>
</tag>
</m>
