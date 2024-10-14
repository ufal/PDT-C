#!/usr/bin/perl

# Map generated XLSX files back to the list of sentences, report
# number of functors per file and in total.

use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use Spreadsheet::ParseXLSX;

sub report($header, $freq) {
    print "$header: ";
    for my $key (sort { $freq->{$b} <=> $freq->{$a} } keys %$freq) {
        print $key, ': ', $freq->{$key}, ' ';
    }
    print "\n";
}

my ($list, @files) = @ARGV;

my $parser = 'Spreadsheet::ParseXLSX'->new;

my %func;
open my $in, '<', $list;
while (<$in>) {
    my ($f, $pos) = m{<<f%(.+?):.*\t.*/(.+)};
    $func{$pos} = $f;
}

my %freq;
for my $file (@files) {
    my $workbook = $parser->parse($file);
    for my $worksheet ($workbook->worksheets) {
        for my $row (1 .. 50) {
            my $cell = $worksheet->get_cell($row, 0);
            my $pos = $cell->value;
            my $func = $func{$pos};
            # say join ' ', $file, $row, $pos, $func;
            ++$freq{TOTAL}{$func};
            ++$freq{$file}{$func};
        }
    }
    report($file, delete $freq{$file});
}
report('TOTAL', $freq{TOTAL});
