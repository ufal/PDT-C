for my $file in $ARGV {
    open $file ;
    my $prefix = xsh:subst($file, '.*/.._(...).*', '$1') ;
    for //pml:m[substring(@id, 1, 1) = "m"] {
        set @id concat('m', $prefix, substring-after(@id, 'm')) ;
    }
    save :b ;
}