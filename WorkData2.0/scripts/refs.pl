#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use XML::LibXML ();

binmode *STDOUT, ':encoding(UTF-8)';

my @files = @ARGV ? @ARGV : glob 'annotators/???/done/*.w';

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => 'http://ufal.mff.cuni.cz/pdt/pml/');

for my $wfile (@files) {
    my %w;
    my $doc = substr $wfile, 0, -2;

    my $wdom = 'XML::LibXML'->load_xml(location => $wfile);
    for my $wnode ($xpc->findnodes('//pml:token/..', $wdom)) {
        $w{ $wnode->{id} } = {
            token => $xpc->findvalue('pml:token', $wnode),
            space => $xpc->findvalue('pml:no_space_after', $wnode)};
    }

    my %m;
    my @delete_w;
    my $mfile = $doc . '.m';
    my $mdom = 'XML::LibXML'->load_xml(location => $mfile);
    for my $ms ($xpc->findnodes('//pml:s', $mdom)) {
        undef $m{s}{ $ms->{id} };
        for my $mnode ($xpc->findnodes('pml:m', $ms)) {
            my $form  = $xpc->findvalue('pml:form', $mnode);
            my $tag   = $xpc->findvalue('pml:tag', $mnode);
            my $lemma = $xpc->findvalue('pml:lemma', $mnode);
            my $id = $mnode->{id};
            $m{m}{$id} = $form;
            # See PML_M_Anot::is_valid_tag.
            say "Invalid tag\t$id\t$tag"
                unless $tag =~ /^[-ABCDFIJNPQRSTVXZ][-#%*,}:=?@^1-9A-Za-z]
                                [-FHIMNQTXYZ][-DPSWX][-1-7X][-FMXZ][-PSX]
                                [-123X][-FHPRX][-123][-AN][-AP][-BIP]
                                [-cemnosz][-1-9abc]\z/x;
            say "Whitespace in lemma\t$id" if $lemma =~ /\s/;
            say "Whitespace in form\t$id"  if $form =~ /\s/;
            my @wids = map s/^w#//r,
                       grep length,
                       map s/\s+//gr,
                       $xpc->findnodes('pml:w.rf//text()', $mnode);
            if (@wids) {
                push @delete_w, @wids;
                for my $wid (@wids) {
                    if (! exists $w{$wid}) {
                        say "Id not found\t$wid";
                    }
                }
                my $form_change = $xpc->findvalue('pml:form_change', $mnode);
                if ('insert' eq ($form_change // "")) {
                    say "form_change=insert with ref\t$id\t$form";
                }
                if (@wids > 1
                    || (1 == @wids && $form ne $w{ $wids[0] }{token})
                ) {
                    say "Missing form change\t$id\t$form != ",
                        join ' ', map $_->{token}, @w{@wids}
                        unless $form_change;
                } elsif (1 == @wids
                         && $form eq $w{ $wids[0] }{token}
                         && $form_change
                     ) {
                    say "Superfluous form change\t$id\t$form.";
                }
            } else {
                my $form_change = $xpc->findvalue('pml:form_change', $mnode);
                if (! $form_change) {
                    say "Missing form_change insert\t$id\t$form";
                } elsif ($form_change ne 'insert') {
                    say "Wrong form_change instead of insert",
                        "\t$id\t$form $form_change";
                }
            }
        }
    }
    delete @w{@delete_w};
    say qq(Not referenced wnode\t$_\t$wfile\t"$w{$_}{token}") for keys %w;

    my %a;
    my @delete_ms;
    my @delete_mm;
    my $afile = $doc . '.a';
    my $adom = 'XML::LibXML'->load_xml(location => $afile);
    for my $anode ($xpc->findnodes('//pml:trees//@id/..', $adom)) {
        my $id = $anode->{id};
        if (my $srf = $xpc->findvalue('pml:s.rf', $anode)) {
            undef $a{r}{$id};
            substr $srf, 0, 2, "";
            push @delete_ms, $srf;
            say "Id not found\t$id\t$srf" unless exists $m{s}{$srf};

            my $ord = $xpc->findvalue('pml:ord', $anode);
            say "Root not ord 0\t$id" unless 0 == $ord;

        } elsif (my $mrf = $xpc->findvalue('pml:m.rf', $anode)) {
            $a{n}{$id} = $xpc->findvalue('pml:afun', $anode);
            substr $mrf, 0, 2, "";
            $a{n}{$id} .= " $m{m}{$mrf}";
            push @delete_mm, $mrf;
            say "Id not found\t$id\t$mrf" unless exists $m{m}{$mrf};

        } else {
            say "No reference to m\t$id";
        }
    }
    delete @{ $m{s} }{@delete_ms};
    delete @{ $m{m} }{@delete_mm};
    say "Not referenced ms\t$_" for keys %{ $m{s} };
    say "Not referenced mnode\t$_\t$m{m}{$_}" for keys %{ $m{m} };

    my $tfile = $doc . '.t';
    next unless -f $tfile;

    my %t;
    my @delete_ar;
    my @delete_an;
    my %mwe;
    my %lex_rf;
    my $tdom = 'XML::LibXML'->load_xml(location => $tfile);
    for my $tnode ($xpc->findnodes('//pml:trees//pml:deepord/..', $tdom)) {
        my $id = $tnode->{id};
        if (my $atrf = $xpc->findvalue('pml:atree.rf', $tnode)) {
            substr $atrf, 0, 2, "";
            push @delete_ar, $atrf;
            say "Root id not found\t$id\t$atrf" unless exists $a{r}{$atrf};

            my $ord = $xpc->findvalue('pml:deepord', $tnode);
            say "Root not deepord 0\t$id" unless 0 == $ord;

            if (my ($mwes) = $xpc->findnodes('pml:mwes', $tnode)) {
                my @refs = grep length,
                           map s/\s+//gr,
                           $xpc->findnodes('.//pml:tnode.rfs//text()', $mwes);
                @mwe{@refs} = ($id) x @refs;
            }

        } else {
            $t{$id} = $xpc->findvalue('pml:t_lemma', $tnode);
            my $is_generated = $xpc->findvalue('pml:is_generated', $tnode);
            if (my ($aref) = $xpc->findnodes('pml:a', $tnode)) {
                my $lex = $xpc->findvalue('substring-after(pml:lex.rf, "a#")',
                                          $aref);
                my @aux = map s/^a#//r,
                          grep length,
                          map s/\s+//gr,
                          $xpc->findnodes('pml:aux.rf//text()', $aref);
                for my $ref (($lex) x !! $lex, @aux) {
                    push @delete_an, $ref;
                    say "Id not found\t$id\t<$ref>" unless exists $a{n}{$ref};
                }

                push @{ $lex_rf{$lex}{$is_generated ? 'gen' : 'nong'} }, $id
                            if $lex;
            }
            if (! $xpc->findnodes('pml:a/pml:lex.rf', $tnode)
                && ! $is_generated
            ) {
                say "Non generated t without lex.rf\t$id";
            }
        }
    }
    for my $ref (keys %mwe) {
        if (! exists $t{$ref}) {
            say "Missing mwe\t$mwe{$ref}\t$ref";
        }
    }
    for my $aid (keys %lex_rf) {
        my @gen = @{ $lex_rf{$aid}{nong} // [] };
        if (@gen != 1) {
            say "More than 1 non-generated\t$aid\t",
                join ' ', @{ $lex_rf{$aid}{nong} }
                if @gen > 1;
            say "All generated\t$aid\t",
                join ' ', @{ $lex_rf{$aid}{gen} }
                if ! @gen;
        }
    }

    delete @{ $a{r} }{@delete_ar};
    delete @{ $a{n} }{@delete_an};
    say "Not referenced a roots\t$_" for keys %{ $a{r} };
    say "Warning: not referenced anode\t$_\t$a{n}{$_}" for keys %{ $a{n} };
}
