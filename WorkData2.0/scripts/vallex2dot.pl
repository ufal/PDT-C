#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use XML::LibXML;

use constant WORD_ID => qr/^(v-w409|v-w1855)$/;

sub idify($id) { $id =~ s/-/_/gr }

{   my %COLOUR = (active      => 'navy',
                  reviewed    => 'black',
                  substituted => 'cyan',
                  obsolete    => 'red');
    sub colour($status) {
        $COLOUR{$status}
    }
}

my $dom = 'XML::LibXML'->load_xml(location => shift);

say 'strict digraph {';

say 'node [shape=oval]; # Words';

for my $word ($dom->findnodes('//word')) {
    next unless $word->{id} =~ WORD_ID;

    say $word->{id} =~ s/-/_/gr, ';';
}

say 'node [shape=box]; # Frames';

for my $word ($dom->findnodes('//word')) {
    next unless $word->{id} =~ WORD_ID;

    for my $frame ($word->findnodes('valency_frames/frame')) {
        my $colour = colour($frame->{status});
        say idify($frame->{id}), qq( [label = "$frame->{id}", color=$colour];);
        say idify($word->{id}), '->',
            idify($frame->{id}), ';';
        if ('substituted' eq $frame->{status}) {
            my $edge_colour = $frame->{substituted_with} =~ / /
                            ? 'red' : 'green';
            for my $s (split ' ', $frame->{substituted_with}) {
                say idify($frame->{id}), ' -> ', idify($s),
                    "[color=$edge_colour];";
            }
        }
    }
}

say '}';
