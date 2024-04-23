for my $t in $ARGV {
    open $t ;
    for /pml:tdata/pml:head/pml:references/pml:reffile[@id='v']/@href
        set . substring-after(., 'resources/') ;
    save :b ;
}