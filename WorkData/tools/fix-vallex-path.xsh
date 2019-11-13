for my $t in $ARGV {
    open $t ;
    set /pml:tdata/pml:head/pml:references/pml:reffile[@id='v']/@href
        'vallex3.xml' ;
    save :b ;
}