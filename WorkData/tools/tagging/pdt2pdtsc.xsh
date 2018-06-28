register-namespace pml http://ufal.mff.cuni.cz/pdt/pml/ ;
for my $file in {@ARGV} {
    open $file ;
    rm (//pml:lemma | //pml:tag) ;
    xinsert element 'tag' into //pml:m ;
    set /pml:mdata/pml:head/pml:schema/@href 'mdata_36_schema.xml' ;
    save :b ;
}
