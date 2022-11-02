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

        my $afile;
        my $workdir = $list->workdir($file->annotator);
        if ($file->done) {
            if ($file->comment =~ /kept/) {
                print 'kept';
                $afile = "$workdir/done/";
            } else {
                print 'dups';
                $afile = join "", $workdir, '/../../duplicates/',
                         $file->annotator, '/';
            }
        } else {
            print 'todo';
            $afile = "$workdir/";
        }
        $afile .= "$mask{$part}.cz.a";
        say "\t", (-f "$afile") ? 'OK' : 'Missing', "\t", $afile;
    } else {
        $mask{$file->comment} = $file->name;
    }
});

