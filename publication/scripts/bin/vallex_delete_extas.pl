#!/usr/bin/perl
# Author: Jiri Mirovsky
# 2020

=item vallex_delete_extras.pl

  Deletes global and local history, and problems from vallex.

=cut

use strict;
use warnings;
use XML::Twig; # pro načtení Vallexu

#encoding utf8
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';


my ($vallex_file) = @ARGV;


# #####################################################################################################################
# read Vallex
# #####################################################################################################################

print STDERR "Going to read Vallex from '$vallex_file'\n";

my $vallex = XML::Twig->new(twig_handlers => {
            local_history => sub { $_->delete() },
            global_history => sub { $_->delete() },
            problems => sub { $_->delete() }
        });
$vallex->parsefile($vallex_file);

# done reading Vallex

$vallex->set_pretty_print ('indented');

$vallex->print;

