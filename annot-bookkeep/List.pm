package List;

use warnings;
use strict;

use Exporter qw{ import };

use constant SVN => "$ENV{HOME}/SVN/pdtc2a";

use enum (qw[ FILE SENTENCES FORMS ANNOTATOR SENT DONE COMMENT ]);
our @EXPORT = qw( FILE SENTENCES FORMS ANNOTATOR SENT DONE COMMENT
                  list workdir );

use FindBin;
my $list = "$FindBin::Bin/list.txt";
-f $list or die "$list not found.\n";

sub list { $list }
sub workdir { "${\SVN}/annotators/$_[0]" }

__PACKAGE__
