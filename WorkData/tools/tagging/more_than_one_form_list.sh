#! /bin/bash
find -name '*.m' -exec xsh -aC '
    quiet ;
    for $f in {@ARGV} {
        open $f ;
        $c = //*[@type="New Form"] ;
        $p = $c/ancestor::pml:m ;
        if not(count($c) = count($p)) echo $f ":" (count($c) - count($p)) ;
    }' {} +
