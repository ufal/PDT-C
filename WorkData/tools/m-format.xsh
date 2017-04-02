for my $file in { @ARGV } {
    open $file ;
    rm //pml:tag[pml:AM]/text()[1] ;
    for //pml:tag[@lemma] {
        rename :n 'http://ufal.mff.cuni.cz/pdt/pml/' 'AM' . ;
        wrap :n 'http://ufal.mff.cuni.cz/pdt/pml/' 'tag' . ;
        xinsert text {"\n"} append .. ;
    }
    save :b ;
}