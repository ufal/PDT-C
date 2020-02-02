#! /bin/bash
find "$1" -name '*.m' -exec xsh -aC '
    quiet ;
    for $f in {@ARGV} {
        open $f ;
        for //pml:comment[.//@type="Other"][.//@type="New Form"]
            echo ancestor::pml:m/@id ;
    }' {} +
