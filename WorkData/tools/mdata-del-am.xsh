for my $f in { glob 'pdtsc_*.mdata' } {
    open $f ;
    for //pml:m[pml:AM/@id] {
        echo pml:AM/@id ;
        
        rename 'pml:m' pml:AM ;
        xmv pml:m replace . ;
    }
    save :b ;
}