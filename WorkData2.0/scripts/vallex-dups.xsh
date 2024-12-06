# Find duplicate functors in frames.
open {shift} ;
for my $frame in //frame {
    for my $func in $frame//@functor {
        if (count($frame//@functor[.=$func]) > 1) {
            echo $frame/../../@lemma $frame/@id $func ;
        }
    }
} | sort -u
