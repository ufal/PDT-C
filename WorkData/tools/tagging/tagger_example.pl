#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

use tagger;
my $tagger = tagger->new('models/czech-morfflex-pdt-161209-devel.tagger');

use Data::Dumper;
print Dumper($tagger->tag('maxipes', 'fikus', '.'));
