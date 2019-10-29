#! /usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use Syntax::Construct qw{ /r };

use XML::LibXML;

my $PML = 'http://ufal.mff.cuni.cz/pdt/pml/';

my @dirs = map glob("$_/*.p/"), map s/ /\\ /gr, @ARGV;
die "No .p directories found.\n" unless @dirs;

for my $dir (@dirs) {
    my $orig = $dir =~ s=\.p/=.m=r;
    my @copies = glob "$dir/*.m";

    my $xpc = 'XML::LibXML::XPathContext'->new;
    $xpc->registerNs(pml => $PML);

    my %comments;
    for my $file ($orig, @copies) {
        my $dom = 'XML::LibXML'->load_xml(location => $file);
        my @mnodes = $xpc->findnodes('//pml:m[pml:comment]', $dom);
        for my $mnode (@mnodes) {
            my $id = $mnode->{id};
            for my $comment (
                $xpc->findnodes('(pml:comment[@type] | pml:comment/pml:LM)',
                                $mnode)
            ) {
                my $text = $xpc->findvalue('pml:text', $comment);
                undef $comments{$id}{ $comment->{type} }{$text}{$file};
            }
        }
    }
    for my $id (keys %comments) {
        for my $type (keys %{ $comments{$id} }) {
            for my $text (keys %{ $comments{$id}{$type} }) {
                my @files = keys %{ $comments{$id}{$type}{$text} };
                next if @files == 1 + @copies;

                for my $file (grep ! exists $comments{$id}{$type}{$text}{$_},
                              @copies, $orig
                ) {
                    my $dom = 'XML::LibXML'->load_xml(location => $file);
                    my ($mnode) = $xpc->findnodes('//pml:m[@id="' . $id . '"]', $dom);
                    my ($comment) = $xpc->findnodes('pml:comment', $mnode);
                    $comment ||= $mnode->addNewChild($PML, 'comment');
                    die "Single element comment not supported"
                        if $comment->{type};
                    my $lm = $comment->addNewChild($PML, 'LM');
                    $lm->{type} = $type;
                    my $lmtext = $lm->addNewChild($PML, 'text');
                    $lmtext->appendText($text);
                    $dom->toFile($file);
                }
            }
        }
    }
}

