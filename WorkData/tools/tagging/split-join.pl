#!/usr/bin/perl
use warnings;
use strict;

use XML::LibXML;

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(p => my $ns = 'http://ufal.mff.cuni.cz/pdt/pml/');


sub join_nodes {
    my ($number, $detail, $m, $text, $comment) = @_;

    my $form = $xpc->findvalue('p:form', $m);
    my $prev_form = $xpc->findvalue('preceding-sibling::p:m[1]/p:form', $m);
    if ($number == 2 && "<$prev_form$form" ne $detail) {
        warn "'<$prev_form$form' ne '$detail' at $m->{id}\n";
    }

    my ($prev_m) = $xpc->findnodes('preceding-sibling::p:m[1]', $m);
    print $prev_m->{id}, "\n";
    print $m->{id}, "\n";
    $prev_m->parentNode->removeChild($prev_m);
    $m->parentNode->removeChild(
        $m->findnodes('preceding-sibling::text()[1]'));
    if ($number > 2) {
        --$number;
        $text->firstChild->setData("1v$number: <$detail");

    } else {
        $comment->{type} = 'New Form';
        $text->firstChild->setData("$prev_form$form");
    }
    return 1
}


sub verify_following {
    my ($m, $detail) = @_;
    my $form = $xpc->findvalue('p:form', $m);
    my $following_form = $xpc->findvalue(
        'following-sibling::p:m[1]/p:form', $m);
    if (">$form$following_form" ne $detail) {
        warn "'>$form$following_form' ne '$detail' at $m->{id}\n";
    }
}


sub split_words {
    my ($new_count, $old_count, $new_text, $m, $comment, $text) = @_;
    my @words = split ' ', $new_text;
    unless (@words == $new_count) {
        warn 'SKIP: ', scalar @words, "!= $new_count at $m->{id}\n";
        return
    }
    if ($old_count > 1) {
        die "Deleting not implemented yet $m->{id}";
    } else {
        for my $i (reverse 1 .. $#words) {
            my $node = $m->cloneNode(1);
            $node->{id} = $node->{id} . "-sw$i";
            my ($old_comment) = $xpc->findnodes('p:comment', $node);
            my $new_comment = 'XML::LibXML::Element'->new('comment');
            my $lm = $new_comment->addNewChild($ns, 'LM');
            $lm->{type} = 'New Form';
            my $text = $lm->addNewChild($ns, 'text');
            $text->appendText($words[$i]);
            $old_comment->replaceNode($new_comment);
            $m->parentNode->insertAfter($node, $m);
        }
        my ($form) = $xpc->findnodes('p:form', $m);

        if ($form->textContent ne $words[0]) {
            warn "Form $words[0] not set $form $m->{id}\n";
            $comment->{type} = 'New Form';
            $text->firstChild->setData($words[0]);

        } else {
            $comment->parentNode->removeChild(
                $comment->findnodes('preceding-sibling::text()[1]'));
            my $top_comment = $comment->localname eq 'LM'
                            ? $comment->parentNode
                            : $comment;
            $comment->parentNode->removeChild($comment);

            unless ($xpc->findvalue('count(p:comment//p:text)', $m)) {
                $top_comment->parentNode->removeChild(
                    $top_comment->findnodes('preceding-sibling::text()[1]'));
                $top_comment->unbindNode;
            }
        }
        print $m->{id}, "\n";
    }
    return 1
}


sub delete_node {
    my ($m) = @_;
    print $m->{id}, "\n";
    $m->parentNode->removeChild($m);
}


binmode *STDOUT, ':encoding(UTF-8)';
binmode *STDERR, ':encoding(UTF-8)';

for my $mfile (@ARGV) {
    my $change;
    my $dom = 'XML::LibXML'->load_xml(location => $mfile)
        or die $mfile;
    for my $m ($xpc->findnodes('/p:mdata/p:s/p:m[p:comment]', $dom)) {
        for my $comment (
            $xpc->findnodes('p:comment[@type] | p:comment/p:LM[@type]', $m)
        ) {
            my $type = $comment->{type};
            my ($text) = $xpc->findnodes('p:text', $comment);

            unless ($type eq 'Other') {
                warn "SKIP: Invalid type: $type at $m->{id}\n";
                next
            }
            if ($text->textContent =~ /1v([0-9]+): ([<>].*)/) {
                my ($number, $detail) = ($1, $2);
                if ($detail =~ /^</) {
                    $change = 1
                        if join_nodes($number, $detail, $m, $text, $comment);

                } elsif ($detail =~ /^>/) {
                    verify_following($m, $detail);
                }
            } elsif ($text->textContent =~ /([0-9]+)v([0-9]+): (.*)/) {
                my ($new_count, $old_count, $new_text) = ($1, $2, $3);
                $change = 1 if split_words(
                        $new_count, $old_count, $new_text, $m, $comment, $text);

            } elsif ($text->textContent eq 'delete') {
                delete_node($m);
                $change = 1;

            } else {
                warn "SKIP: Cannot parse\t'" . $text->textContent
                    . "' at $m->{id}\n";
            }
        }
    }
    next unless $change;

    open my $out, '>:raw', $mfile or die "$mfile: $!";
    $dom->toFH($out);
    close $out;
}

