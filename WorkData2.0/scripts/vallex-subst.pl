#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use List::Util qw{ uniq };
use XML::LibXML;

my $vallex = 'XML::LibXML'->load_xml(location => shift);

my %frame;
sub by_id {
    my ($id) = @_;
    return $frame{$id}
}

sub is_valid {
    my ($frame) = @_;
    $frame->{status} =~ /^active$|^reviewed$|^new-(?:complete|form)$/ ? 1 : 0;
}

sub vs {
    my ($id) = @_;

    my (@frames) = by_id($id);
    my @resolve;
    my %resolved;
    while (@resolve = grep $_->{status} eq 'substituted', @frames) {
        @resolved{ map $_->{id}, @resolve } = ();
        @frames = uniq(grep ! exists $resolved{ $_->{id} },
                       @frames,
                       map by_id($_),
                       map { split / /, $_->{substituted_with} }
                       @resolve);
        say "\t$id -> ", join ', ', sort map $_->{id}, @frames;
    }
    my @valid = grep is_valid($_), @frames;
    if (@valid != 1) {
        say "! $id: ", join ', ', map $_->{id}, @valid;
    } elsif ($frames[0]{id} ne $id) {
        say "$id -> ", $valid[0]{id}, " ($valid[0]{status})";
    } else {
        say "ok $id ($valid[0]{status})";
    }
}

$frame{ $_->{id} } = $_ for $vallex->findnodes('//frame');
vs($_) for sort keys %frame;

=head1 NAME

vallex-subst.pl - Solve substitutions in vallex.

=head1 SYNOPSIS

 vallex-subst.pl /path/to/vallex-1.xml > vs.o

=head1 DESCRIPTION

For each frame in the vallex, find its transitive substitution. Report
problems (no or more than one substitution).

Use the output to populate L<obsolete-frames.btred>.

=cut
