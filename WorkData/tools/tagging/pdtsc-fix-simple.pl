#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use open IO => ':encoding(UTF-8)', ':std';

sub fix {
    my ($mdata, $previous, $old, $new) = @_;
    my $mdata_file = "WorkData/PDTSC/data/$mdata.mdata";
    open my $in, '<', $mdata_file or die $!;
    open my $out, '>', "$mdata_file.new" or die $!;
    my $here;
    while (<$in>) {
        chomp;
        if (m{<form/?>}) {
            my $form = s/ *<.*?>//gr;
            if ($here && $form eq $old) {
                say "Changed $old -> $new.";
                $_ = "    <form>$new</form>";
            }
            $here = $form eq $previous;
        }
        print {$out} $_, "\n";
    }
    close $out;
    rename "$mdata_file.new", $mdata_file or die $!;
}

my ($m, $mdata, $previous);
while (<>) {
    next if /^(?:---|\+{3}) /;

    if (/^(.._...) (pdtsc_..._.)$/) {
        ($m, $mdata) = ($1, $2);
        say "$m $mdata";

    } elsif (/^ (.*)/) {
        $previous = $1;

    } elsif (/^-(.*)/) {
        my $old = $1;
        $_ = <>;
        if (/^\+(.*)/) {
            my $new = $1;
            fix($mdata, $previous, $old, $new);
        } else {
            $_ = <> until /^[+ ]/;
        }
    }
}

