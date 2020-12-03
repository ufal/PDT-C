#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Data::Printer;
use Text::Diff;

sub read_data {
    my ($path) = @_;
    open my $fh, "<:utf8", $path;
    my $data = [];
    my $curr_sent_id = undef;
    my $sent_data = [];
    while (<$fh>) {
        chomp $_;
        my ($id, $token) = split /\t/, $_;
        $id =~ s/^.*\///;
        $id =~ s/wsj_/wsj/g;
        my $sent_id = $id;
        $sent_id =~ s/\.[^.]*$//;
        if (defined $curr_sent_id and $curr_sent_id ne $sent_id) {
            push @$data, $sent_data;
            $sent_data = [];
        }
        push @$sent_data, [$id, $token];
        $curr_sent_id = $sent_id;
    }
    return $data;
}

binmode STDOUT, ":utf8";

print STDERR "Reading old data...\n";
my $old_data = read_data($ARGV[0]);
print STDERR "Reading new data...\n";
my $new_data = read_data($ARGV[1]);

for (my $i = 0; $i < scalar(@$old_data); $i++) {
    my $old_sent = join "\n", map {$_->[1]} @{$old_data->[$i]};
    my $new_sent = join "\n", map {$_->[1]} @{$new_data->[$i]};
    my $diff = diff \$old_sent, \$new_sent, {CONTEXT => 0};
    if (length $diff > 0) {
        print "======= SENTENCE $i =======\n";
        print $diff."\n";
    }
}
