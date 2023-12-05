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
    my $workdir;
    my $name = $file->name;
    if ($file->annotator eq 'ALL' || ($file->comment // "") =~ /mam|learn/) {
        my @files = glob $list->svn . '/annotators/???/done/' . $file->name . '.cz.a';
        say "No files found for ", $file->name unless @files;
        $workdir = $files[0] =~ s{/done/wsj....\.cz\.a}{}r;

    } elsif (($file->comment // "") !~ /dup|lrec|all/) {
        $workdir = $list->workdir($file->annotator);
        $mask{ $file->comment } = $file->name
            if ($file->comment // "") =~ /^\w[0-9]{3}$/;

    } elsif ($file->comment =~ /dup-([0-9]+)|all/) {
        my $shift = $1 || 0;
        my ($char) = $file->name =~ /wsj(.)/;
        if ($char !~ /[0-9]/) {
            $char =~ tr/vwz/xxx/ if $char =~ /[vwz]/;
            $char = (1 + ord($char) - ord('a')) % 3;
        } else {
            $char -= $shift;
        }
        $name = $file->name;
        substr $name, 3, 1, $char;
        $workdir = $list->workdir($file->annotator);

    } elsif ($file->comment =~ /lrec/) {
        $workdir = $list->svn . '/lrec/' . $file->annotator;
        $name =~ s/j([345])/'j' . ($1 % 3)/e;

    } else {
        say "Dunno ", $file->name, ' ', $file->comment;
        return
    }

    $name = $mask{$name} if exists $mask{$name};
    my $full_path = "$workdir/done/" . $name . '.cz.a';
    $full_path =~ s{/done}{} if ($file->comment // "") =~ /lrec/;
    unless (-e $full_path) {
        # There's a duplicate, try that instead.
        if (($file->comment // "") =~ /dup-|all/) {
            if (my @files = glob
                            $list->svn . "/annotators/???/done/$name.cz.a"
            ) {
                count($file->name, $files[0], $file->sentences, $file->forms);
                return
            }
        }
        say "Not found ${\$file->name} at $full_path ", $file->comment;
        return
    }

    for my $layer (qw( m t w )) {
        my $lfile = $full_path =~ s/a$/$layer/r;
        say "Not found layer $lfile ", $file->name, ' ', $file->comment
            if ! -e $lfile && $file->comment !~ /;$layer:/;
    }

    count($file->name, $full_path, $file->sentences, $file->forms);
});

sub count {
    my ($name, $full_path, $count_s, $count_m) = @_;
    open my $in, '<', $full_path =~ s/a$/m/r or die $!;
    my $tally_s = 0;
    my $tally_m = 0;
    while (<$in>) {
        ++$tally_s while /<s /g;
        ++$tally_m while /<m /g;
    }
    say "$name at $full_path sentences: found $tally_s, expected $count_s"
        unless $tally_s == $count_s;
    say "$name at $full_path forms: found $tally_m, expected $count_m"
        unless $tally_m == $count_m;
}

__END__

    if ($file->annotator ne 'ALL' || $file->comment !~ /[a-z][0-9]{3}/) {
        my ($part) = $file->name =~ /wsj(....)/;

        my $workdir = $list->workdir($file->annotator);
        my %afile = (kept => "$workdir/done/",
                     dups => join("", $workdir, '/../../duplicates/',
                                      $file->annotator, '/'),
                     todo => "$workdir/");
        my $type;
        if ($file->done) {
            if (($file->comment // "") =~ /kept/) {
                $type = 'kept';
            } else {
                $type = 'dups';
            }
        } else {
            $type = 'todo';
        }
        my $afile = exists $mask{$part}
                    ? $afile{$type} . "$mask{$part}.cz.a"
                    : $afile{$type} . "$part.cz.a";

        if (! exists $mask{$part} && $file->annotator ne 'ALL') {
            if (-e $afile) {
            }
        }

        return unless exists $mask{$part};

        say "$type\t", (-f $afile) ? 'OK' : 'Missing', "\t", $afile;
        for my $other (grep $_ ne $type, sort keys %afile) {
            my $ofile = $afile{$other} . "$mask{$part}.cz.a";
            say "sur+\tSur+\t$file" if -e $ofile;
        }

        for my $layer (qw( m t w )) {
            my $lfile = $afile{$type} . "$mask{$part}.cz.$layer";
            say "todo\tMissing $lfile" unless -e $lfile;
        }
    } else {
        $mask{$file->comment} = $file->name;
    }
});

