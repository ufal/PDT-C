for my $file in $ARGV {
    open $file ;
    my $prefix = xsh:subst($file, '.*/.._(...).*', '$1') ;
    for //pml:m.rf[substring(., 3, 1) = "m"] {
        set text() concat(substring-before(., '#'), '#m', $prefix, "-",
                          substring-after(., '-')) ;
    }
    save :b ;
}
