# Reflect changes in morphlex into the data.

verbose ;
my $h = {+{
    'to-9_^(být_s_to)' => {'TT-------------' => ['to-1_^(tehdy;to_jsem_byla_ještě_malá)', 'PDXXX----------']},
    'takže'            => {'J,-------------' => ['takže',                                 'J^-------------']},
    'taky'             => {'Db-------------' => ['taky_,s_^(^DD**také)',                  'TT-------------']},
    'také'             => {'Db-------------' => ['také',                                  'TT-------------']},
    'též'              => {'Db-------------' => ['též',                                   'TT-------------']},
    'opravdu-1'        => {'Db-------------' => ['opravdu',                               'TT-------------']},
    'opravdu-2'        => {'TT-------------' => ['opravdu',                               'TT-------------']},
    'hlavně_^(*1í)'    => {'Dg-------1A----' => ['hlavně-2',                              'TT-------------']},
}} ;
my $f ;
while {$f = shift @ARGV} {
    my $changed ;
    my $m := open $f ;
    for my $l in $m//pml:lemma/text() {
        if {exists $h->{$l}} {
            my $p = $l/../.. ;
            my $t = $l/../../pml:tag/text() ;
            if {exists $h->{$l}{$t}} {
                insert text { $h->{$l}{$t}[0] } replace $l ;
                insert text { $h->{$l}{$t}[1] } replace $t ;
                $changed = 1;
            }
        }
    }
    if $changed save :b $m ;
}
