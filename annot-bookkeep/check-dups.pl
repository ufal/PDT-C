#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;
use lib $FindBin::Bin;

use List;

my $list = 'List::Builder::Config'->new->build;

my %mask;
$list->for_each(sub {
    my (undef, $file) = @_;
    if ($file->annotator ne 'ALL' || $file->comment !~ /[a-z][0-9]{3}/) {
        my ($part) = $file->name =~ /wsj(....)/;
        return unless exists $mask{$part};

        my $workdir = $list->workdir($file->annotator);
        my %afile = (kept => "$workdir/done/",
                     dups => join("", $workdir, '/../../duplicates/',
                                      $file->annotator, '/'),
                     todo => "$workdir/");
        my $type;
        if ($file->done) {
            if ($file->comment =~ /kept/) {
                $type = 'kept';
            } else {
                $type = 'dups';
            }
        } else {
            $type = 'todo';
        }
        my $file = $afile{$type} . "$mask{$part}.cz.a";
        say "$type\t", (-f $file) ? 'OK' : 'Missing', "\t", $file;
        for my $other (grep $_ ne $type, sort keys %afile) {
            my $file = $afile{$other} . "$mask{$part}.cz.a";
            say "sur+\tSur+\t$file" if -e $file;
        }
    } else {
        $mask{$file->comment} = $file->name;
    }
});

