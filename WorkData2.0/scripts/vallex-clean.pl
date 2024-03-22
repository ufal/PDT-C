#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use List::Util qw{ uniq first };
use POSIX qw{ setlocale LC_ALL };
use XML::LibXML;

sub serialize_form_nodes {
    my ($node) = @_;
    my $ret = "";
    for my $element (
        grep $_->nodeType == XML_ELEMENT_NODE, $node->childNodes
    ) {
        if ($element->nodeName eq 'parentpos') {
            $ret .= '&';
        } else {
            $ret .= ',' if $ret ne "" and $ret !~ /\&$/;
            $ret .= serialize_form($element) // "";
        }
    }
    my $rare = $node->{rare};
    $ret .= '%' x $rare if $rare;
    return $ret
}

sub serialize_form {
    my ($node) = @_;

    if ($node->nodeName eq 'form') {
        if ($node->getChildrenByTagName('elided')) {
            return '!'
        } elsif ($node->getChildrenByTagName('typical')) {
            return '*'
        } elsif ($node->getChildrenByTagName('state')) {
            return '='
        } elsif ($node->getChildrenByTagName('recip')) {
            return '%'
        } else {
            return serialize_form_nodes($node);
        }
    } elsif ($node->nodeName eq 'parent') {
        my $ret = '^' . serialize_form_nodes($node);
    } elsif ($node->nodeName eq 'node') {
        my $ret;
        if ($node->{form}) {
            $ret = '"' . $node->{form} . '"';
        } else {
            $ret = $node->{lemma};
        }
        my $morph = "";
        $morph = '~' if ($node->{neg} // "") eq 'negative';
        $morph .= join "", map $node->{$_} // "", qw( pos gen num case );
        $morph .= '@' . $node->{deg} if ($node->{deg} // "") ne "";
        $morph .= '#' if ($node->{agreement} // 0) == 1;
        for (1..15) {
            if (my $tag = $node->{"tagpos$_"}) {
                $morph .= "\$$_\<${tag}\>";
            }
        }
        my $afun = $node->{afun};
        if (($afun // "") ne "" && $afun ne "unspecified") {
            $ret .= "/$afun";
        }
        my $inherits = $node->{inherits};
        $ret .= (($inherits // 0) == 1 ? '.' : ':') . $morph
            if ($inherits // 0) == 1 || $morph ne "";
        if ($node->getChildrenByTagName('node')) {
            $ret .= '[' . join(',',
                               map serialize_form($_),
                               $node->getChildrenByTagName('node'))
                  . ']';
        }
        return $ret;
    } elsif ($node->nodeName ne 'parentpos') {
        print STDERR join(" ",caller($_))."\n" for 1..5;
        die "Can't serialize unknown node-type ", $node->nodeName(),"\n";
    }
}

sub serialize_forms {
    my ($element) = @_;
    my @forms;
    for my $form ($element->getChildrenByTagName('form')) {
        push @forms, serialize_form($form);
    }
    return join ';', @forms
}

sub serialize_element {
    my ($element) = @_;
    if ($element->nodeName eq 'element') {
        my $functor = $element->{functor};
        $functor .= '%' if ($element->{rare} // 0) == 1;
        my $type = $element->{type};
        my $forms = serialize_forms($element);
        return ($type eq 'oblig' ? '' : '?') . "$functor($forms)";
    } elsif ($element->nodeName eq 'element_alternation') {
        return join '|', map serialize_element($_),
            $element->getChildrenByTagName ('element')
    }
}

sub is_oblig($element_or_alt) {
    if ($element_or_alt->nodeName eq 'element') {
        return $element_or_alt->{type} eq 'oblig' ? 1 : 0
    } elsif ($element_or_alt->nodeName eq 'element_alternation') {
        return 1
    }
}

sub serialize_frame {
    my ($frame) = @_;
    my @elements;
    my @element_nodes = $frame->findnodes('(frame_elements/element | frame_elements/element_alternation)');

    for my $element (grep is_oblig($_), @element_nodes) {
        push @elements, serialize_element($element);
    }
    push @elements, '  ' if @elements;
    for my $element (grep ! is_oblig($_), @element_nodes) {
        push @elements, serialize_element($element);
    }
    my $ret = join '  ', @elements;
    my $rare = $frame->{rare};
    $ret .= ' ' . ('%' x $rare) if $rare;
    return $ret
}

sub indentation($n) {
    return "\n" . ' ' x $n
}

sub remove_child_plus_whitespace($child, $parent) {
    my $next = $child->nextSibling;
    $next->unbindNode if $next && $next->findnodes('self::text()');
    return $parent->removeChild($child);
}

sub add_child($parent, $child, $n) {
    $parent->addChild(
        'XML::LibXML::Text'->new(indentation($n)));
    $parent->addChild($child);
}

sub fdelete($frame) {
    say STDERR "Deleting $frame->{status} $frame->{id}.";
    my $next = $frame->nextSibling;
    $next->unbindNode if $next && $next->findnodes('self::text()');
    $frame->unbindNode;
}

sub fix_indentation($node, $n) {
    my $endspace = $node->lastChild;
    if ($endspace && $endspace->findnodes('self::text()')) {
        $endspace->setData(indentation($n));
    } else {
        $node->addChild(
            'XML::LibXML::Text'->new(indentation($n)));
    }
    my $startspace = $node->firstChild;
    if ($startspace
        && $startspace->findnodes('self::text()')
        && $startspace->findnodes('self::text()') =~ /\n.*\n/
    ) {
        $startspace->setData(indentation($n + 2));
    }
}

sub order_lemmata($frame) {
    for my $element ($frame->findnodes(
        'frame_elements/element[@functor="CPHR"]')
    ) {
        my @lemmata = $element->findnodes('form/node/@lemma');
        for my $lemma (@lemmata) {
            my $lemma_str = $lemma->getValue;
            $lemma_str =~ s/^ \{ | \} $//gx
                or warn "Missing brackets at $lemma_str.";
            my @l = do {
                use locale;
                setlocale(LC_ALL, 'cs_CZ.UTF-8');
                uniq(sort split /,/, $lemma_str)
            };
            push @l, shift @l if $l[0] eq '...';
            my $value = join ',', @l;
            $value = "{$value}" if @l > 1;
            $lemma->setValue($value);
            warn "LEMMATA: $lemma_str\n         $value"
                if $value !~ /\{?$lemma_str\}?/;
        }
    }
}

sub functor_or_first_alt($element) {
    return (($element->nodeName eq 'element_alternation')
            ? ($element->findnodes('element[1]'))[0]
            : $element
        )->{functor}
}

my %FUNC_ORDER = do {
    my $order = 0;
    map { $_ => $order++ }
        qw( ACT CPHR DPHR PAT ADDR ORIG EFF BEN LOC DIR1 DIR2 DIR3
            TWHEN TFRWH TTILL TOWH TSIN TFHL MANN MEANS ACMP EXT INTT
            MAT APP CRIT REG )
};

$FUNC_ORDER{default} = keys %FUNC_ORDER;
sub by_functor {
    (($FUNC_ORDER{ functor_or_first_alt($a) } // $FUNC_ORDER{default})
     <=>
     ($FUNC_ORDER{ functor_or_first_alt($b) } // $FUNC_ORDER{default}))
    ||
    (functor_or_first_alt($a) cmp functor_or_first_alt($b))
}

sub order_alternation($alt) {
    local $FUNC_ORDER{MANN} = -1;
    my @elements = sort by_functor $alt->findnodes('element');
    for my $e (@elements) {
        remove_child_plus_whitespace($e, $alt);
        add_child($alt, $e, 14);
    }
    fix_indentation($alt, 12);
}

sub order_participants($frame) {
    my $frame_elements = ($frame->findnodes('frame_elements'))[0];
    for my $alt ($frame_elements->findnodes('element_alternation')) {
        order_alternation($alt);
    }
    my @obligatory = $frame_elements->findnodes(
        '( element[@type="oblig"] | element_alternation )');
    my @non_obligatory = $frame_elements->findnodes(
        'element[@type="non-oblig"]');
    for my $group (\@obligatory, \@non_obligatory) {
        my @sorted = sort by_functor @$group;
        for my $e (@sorted) {
            remove_child_plus_whitespace($e, $frame_elements);
            add_child($frame_elements, $e, 12);
        }
    }
    fix_indentation($frame_elements, 10);
}

sub frame_sort {
    my $size_a = $a->findvalue('count(frame_elements/*)');
    my $size_b = $b->findvalue('count(frame_elements/*)');
    my $cmp_size = $size_b <=> $size_a;
    return $cmp_size if $cmp_size;

    my @elems_a = $a->findnodes('frame_elements/*');
    my @elems_b = $b->findnodes('frame_elements/*');

    my @func_a = map $FUNC_ORDER{ functor_or_first_alt($_) }
                     // $FUNC_ORDER{default},
                 @elems_a;
    my @func_b = map $FUNC_ORDER{ functor_or_first_alt($_) }
                     // $FUNC_ORDER{default},
                 @elems_b;
    for my $i (0 .. $size_a - 1) {
        my $cmp = $func_a[$i] <=> $func_b[$i];
        return $cmp if $cmp;
    }

    for my $i (0 .. $size_a - 1) {
        my $cmp = ($elems_b[$i]{type} // 'oblig')
                   cmp ($elems_a[$i]{type} // 'oblig');
        return $cmp if $cmp;
    }

    # TODO: Frequency?

    my $cmp = serialize_frame($a) cmp serialize_frame($b);
    return $cmp if $cmp;

    $cmp = $a->findvalue('example') cmp $b->findvalue('example');
    return $cmp if $cmp;

    die "Uncomparable $a\n$b";
}

# Returns false if there are no frames.
sub order_frames($word, $valency_frames) {
    my (@empty, @cphr, @dphr, @rest);
    for my $frame ($valency_frames->findnodes('frame')) {
        my $group;
        if (! $frame->hasChildNodes) {
            $group = \@empty;

        } elsif ($frame->findnodes(
            'frame_elements/element[@functor="CPHR"]')
        ) {
            $group = \@cphr;

        } elsif ($frame->findnodes(
            'frame_elements/element[@functor="DPHR"]')
        ) {
            $group = \@dphr;

        } else {
            $group = \@rest;
        }

        push @$group, remove_child_plus_whitespace($frame, $valency_frames);
    }

    if (! (@cphr + @dphr + @empty + @rest)) {
        warn "No frames left in $word->{lemma}.";
        $word->unbindNode;
        return 0
    }

    for my $frame (@cphr) {
        order_lemmata($frame);
    }

    for my $group (\@rest, \@cphr, \@dphr, \@empty) {
        next unless @$group;

        for my $frame (@$group) {
            order_participants($frame);
        }
        for my $frame (sort frame_sort @$group) {
            add_child($valency_frames, $frame, 8);
        }
    }

    fix_indentation($valency_frames, 6);
    return 1
}

sub test {
    require Test2::V0;
    'Test2::V0'->import(qw{ plan is subtest });
    plan(3);

    {   my $alt = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
                    <element_alternation>
                      <element functor="DEF"/>
                      <element functor="ABC"/>
                      <element functor="MAT"/>
                      <element functor="EXT"/>
                      <element functor="MANN"/>
                    </element_alternation>
        __XML__
        order_alternation($alt->documentElement);
        is([map $_->{functor}, $alt->findnodes('element_alternation/element')],
           [qw[ MANN EXT MAT ABC DEF ]],
           'order alternation');
    }

    {   my $frame = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
                <frame>
                  <frame_elements>
                    <element functor="BEN" type="non-oblig"/>
                    <element functor="REG" type="non-oblig"/>
                    <element functor="EXT" type="oblig"/>
                    <element functor="EFF" type="oblig"/>
                    <element_alternation>
                      <element functor="MANN" type="oblig"/>
                      <element functor="TSIN" type="oblig"/>
                      <element functor="APP" type="oblig"/>
                    </element_alternation>
                    <element functor="ACT" type="oblig"/>
                  </frame_elements>
                </frame>
        __XML__
        order_participants($frame->documentElement);
        is([map $_->{functor}, $frame->findnodes('//element')],
           [qw[ ACT EFF MANN TSIN APP EXT BEN REG ]],
           'order_participants');
    }

    subtest('order frames' => sub {
        plan(4);
        my $frames = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
              <valency_frames>
                <frame>
                  <frame_elements>
                      <element functor="ACT" type="oblig"/>
                  </frame_elements>
                </frame>
                <frame>
                  <frame_elements>
                      <element functor="ACT" type="oblig"/>
                      <element functor="PAT" type="oblig"/>
                  </frame_elements>
                </frame>
              </valency_frames>
        __XML__
        order_frames(undef, $frames->documentElement);
        is([map $_->{functor}, $frames->findnodes('.//element')],
           [qw[ ACT PAT ACT ]],
           'ACT PAT -> ACT');

        $frames = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
              <valency_frames>
                <frame>
                  <frame_elements>
                      <element functor="ACT" type="oblig"/>
                      <element functor="PAT" type="non-oblig"/>
                  </frame_elements>
                </frame>
                <frame>
                  <frame_elements>
                      <element functor="ACT" type="oblig"/>
                      <element functor="PAT" type="oblig"/>
                  </frame_elements>
                </frame>
              </valency_frames>
        __XML__
        order_frames(undef, $frames->documentElement);
        is([map serialize_frame($_) =~ s/ +/ /gr,
            $frames->findnodes('//frame')],
           ['ACT() PAT() ', 'ACT() ?PAT()' ],
           'ACT PAT -> ACT ?PAT');

        $frames = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
              <valency_frames>
                <frame>
                  <frame_elements>
                    <element functor="ACT" type="oblig"><form>
                      <node case="1" inherits="1"/>
                    </form><form>
                      <node pos="c" inherits="1"/>
                    </form></element>
                  </frame_elements>
                </frame>
                <frame>
                  <frame_elements>
                    <element functor="ACT" type="oblig"><form>
                      <node inherits="1" case="1"/>
                    </form></element>
                  </frame_elements>
                </frame>
              </valency_frames>
        __XML__
        order_frames(undef, $frames->documentElement);
        is([map serialize_frame($_) =~ s/ +$//r, $frames->findnodes('//frame')],
           ['ACT(.1)', 'ACT(.1;.c)' ],
           'ACT(1) -> ACT(1;c)');

        $frames = 'XML::LibXML'->load_xml(string => <<~ '__XML__');
              <valency_frames>
                <frame>
                  <frame_elements>
                    <element functor="ACT" type="oblig"><form>
                      <node case="2" inherits="1"/>
                    </form><form>
                      <node pos="c" inherits="1"/>
                    </form></element>
                  </frame_elements>
                </frame>
                <frame>
                  <frame_elements>
                    <element functor="ACT" type="oblig"><form>
                      <node inherits="1" case="1"/>
                    </form></element>
                  </frame_elements>
                </frame>
              </valency_frames>
        __XML__
        order_frames(undef, $frames->documentElement);
        is([map serialize_frame($_) =~ s/ +$//r, $frames->findnodes('//frame')],
           ['ACT(.1)', 'ACT(.2;.c)' ],
           'ACT(1) -> ACT(2;c)');
    });
}

sub main($file) {
    my $vallex = 'XML::LibXML'->load_xml(location => shift);
    binmode *STDERR, ':encoding(UTF-8)';

    # Delete invalid frames.

    for my $frame ($vallex->findnodes('//frame')) {
        next if $frame->{status} =~ /^(active|reviewed)$/;

        fdelete($frame);
    }

    # Rename ids, reorder frames.

    my $word_counter = 'a';
    for my $word ($vallex->findnodes('//word')) {
        $word->{id} = "v41$word_counter";

        my $valency_frames = ($word->findnodes('valency_frames'))[0];
        order_frames($word, $valency_frames)
            or next;  # No frames, don't increment word_counter.

        my $frame_counter = 'A';
        for my $frame ($word->findnodes('.//frame')) {
            my $new_id = "$word->{id}$frame_counter";
            say STDERR "$frame->{id}\ -> $new_id";
            $frame->{id} = "$word->{id}$frame_counter";

            ++$frame_counter;
        }

        ++$word_counter;
    }
    print $vallex->toString;
}

if ($ARGV[0] eq '-t') {
    test();
} else {
    main(shift);
}

=head1 NAME

vallex-clean.pl - Remove obsolete and substituted frames from vallex.

=head1 SYNOPSIS

 vallex-clean.pl pdt-vallex-4.0.xml > pdt-vallex-4.1.xml 2>vr.e
 vallex-clean.pl -t

=head1 DESCRIPTION

Before using this script, make sure all substitutions in the data have been
resolved. The script makes no checks, it assumes only C<active> and
C<reviewed> frames should stay. See L<vallex-resolve.btred>.

The STDERR of the script contains input to L<vallex-rename.btred>. Use it to
rename the frame references in the data.

If called with C<-t>, run tests.

=cut
