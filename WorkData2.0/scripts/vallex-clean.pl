#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use XML::LibXML;

my $vallex = 'XML::LibXML'->load_xml(location => shift);

sub fdelete($frame) {
    say STDERR "Deleting $frame->{status} $frame->{id}.";
    my $next = $frame->nextSibling;
    $next->unbindNode if $next =~ /^\s+$/m;
    $frame->unbindNode;
}
for my $frame ($vallex->findnodes('//frame')) {
    next if $frame->{status} =~ /^(active|reviewed)$/;

    fdelete($frame);
}

my $word_counter = 'a';
for my $word ($vallex->findnodes('//word')) {
    $word->{id} = "v41$word_counter";

    my $frame_counter = 'A';
    for my $frame ($word->findnodes('.//frame')) {
        my $new_id = "$word->{id}$frame_counter";
        say STDERR "$frame->{id}\ -> $new_id";
        $frame->{id} = "$word->{id}$frame_counter";

        ++$frame_counter;
    }

    ++$word_counter;
}
print $vallex;

=head1 NAME

vallex-clean.pl - Remove obsolete and substituted frames from vallex.

=head1 SYNOPSIS

 vallex-clean.pl pdt-vallex-4.0.xml > pdt-vallex-4.1.xml

=head1 DESCRIPTION

Before using this script, make sure all substitutions in the data have been
resolved. The script make no checks, it assumes only C<active> and C<reviewed>
frames should stay.

The STDERR of the script contains input to C<vallex-rename.btred>. Use it to
rename the frame references in the data.

=cut
