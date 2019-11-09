for my $file in $ARGV {
    open $file ;
    for //@lemma/parent::*[not(@src)]
        set @src 'auto' ;
    save :b ;
}