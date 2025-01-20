#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use XML::LibXML;
use Text::Table;

my @globs = qw( WorkData2.0/PCEDT-cz/pml/*/*.m
                WorkData2.0/PDTSC/pml/*/*.m
                WorkData2.0/PDT/pml/tamw/*/*.m
                WorkData2.0/PDT/pml/amw/*/*.m
                WorkData2.0/PDT/pml/mw/*/*.m );

my $tt = 'Text::Table'->new("corp\n&left", map { \'|', "$_\n&right" }
                            'avg', 'avg(avg per file)',
                            'min', 'max', 'avg min', 'avg max');

my $xpc = 'XML::LibXML::XPathContext'->new;
$xpc->registerNs(pml => 'http://ufal.mff.cuni.cz/pdt/pml/');

for my $glob (@globs) {
    my $form_per_sent_corp = 0;
    my $sent_per_corp = 0;
    my $form_per_corp = 0;
    my $file_tally = 0;
    my $sum_min = 0;
    my $sum_max = 0;
    my $avg_min = 1_000_000;
    my $avg_max = 0;

    say STDERR $glob;
    for my $file (glob $glob) {
        my $dom = 'XML::LibXML'->load_xml(location => $file);
        my $sent_per_file = $xpc->findvalue('count(//pml:s)', $dom);
        my $form_per_file = $xpc->findvalue('count(//pml:m)', $dom);
        my $form_per_sent_file = $form_per_file / $sent_per_file;
        $form_per_sent_corp += $form_per_sent_file;
        $sent_per_corp += $sent_per_file;
        $form_per_corp += $form_per_file;
        ++$file_tally;

        my $min = $form_per_file + 1;
        my $max = 0;
        for my $s ($xpc->findnodes('//pml:s', $dom)) {
            my $form_per_sent = $xpc->findvalue('count(pml:m)', $s);
            $min = $form_per_sent if $form_per_sent < $min;
            $max = $form_per_sent if $form_per_sent > $max;
        }
        $sum_min += $min;
        $sum_max += $max;

        $avg_min = $form_per_sent_file if $form_per_sent_file < $avg_min;
        $avg_max = $form_per_sent_file if $form_per_sent_file > $avg_max;
    }


    my $name = (split m{/}, $glob)[1];
    $name .= '/' . (split m{/}, $glob)[3] if 'PDT' eq $name;

    $tt->add($name,
             map { sprintf '%.2f', $_ }
                 $form_per_corp / $sent_per_corp,
                 $form_per_sent_corp / $file_tally,
                 $sum_min / $file_tally,
                 $sum_max / $file_tally,
                 $avg_min,
                 $avg_max);
}
print $tt;
