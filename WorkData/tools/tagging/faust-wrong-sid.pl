#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

my $dir = shift;
for my $mfile (glob "$dir/*.m") {
    my @sids;
    open my $m_in, '<', $mfile or die $!;
    while (<$m_in>) {
        push @sids, /<s id="([^"]+)"/;
    }
    my $afile = $mfile =~ s/m$/a/r;
    rename $afile, "$afile~" or die $!;
    open my $a_in, '<', "$afile~" or die $!;
    open my $a_out, '>', $afile or die $!;
    while (<$a_in>) {
        s/<s\.rf>m#\Km-s1(?=<)/warn "EMPTY" unless @sids; shift @sids/e;
        print {$a_out} $_;
    }
    warn "@sids" if @sids;
}

