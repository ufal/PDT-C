quiet ;
my $pml_ns = 'http://ufal.mff.cuni.cz/pdt/pml/' ;
register-namespace pml $pml_ns ;
my $MHEAD = '<head><schema href="mdata_36_schema.xml"/><references><reffile id="w" name="wdata" href="h"/></references></head>' ;
my $WHEAD = '<head><schema href="wdata_30_schema.xml"/></head>' ;

define split_node $a $s {
    my $mid = substring-after($a/pml:m.rf, 'm#') ;
    my $m := xmv $a/pml:m append $s ;
    rm $a/pml:ord/following-sibling::text()[2] ;
    set $m/@id $mid ;
    cp $a/pml:ord into $m ;
    for my $ch in ( $a/pml:children/pml:LM
                  | $a/pml:children[0 = count(pml:LM)] ) {
        split_node $ch $s ;
    }
}

for my $afile in $ARGV {
    my $adoc := open $afile ;

    my $mfile = concat(substring-before($afile, '.a'), '.m') ;
    my $mdoc := create concat('<mdata xmlns="', $pml_ns, '"/>') ;
    my $mdata = $mdoc/pml:mdata ;
    insert :n $pml_ns element head prepend $mdata ;
    insert :n $pml_ns element '<schema href="mdata_36_schema.xml"/>'
        into $mdata/pml:head ;
    insert :n $pml_ns element '<references>' after $mdata/pml:head/pml:schema ;
    insert :n $pml_ns element '<reffile id="w" name="wdata" href="">'
        into $mdata/pml:head/pml:references ;

    my $wfile = concat(substring-before($afile, '.a'), '.w') ;
    my $wdoc := create concat('<wdata xmlns="', $pml_ns, '"/>') ;
    my $wdata = $wdoc/pml:wdata ;
    insert chunk $WHEAD into $wdata ;

    my $doc := insert element pml:doc into $wdata ;
    insert element pml:docmeta into $doc ;
    my $para := xinsert element pml:para into $doc ;
    set $doc/@id xsh:subst($wfile, '.*/', '') ;

    set $adoc/pml:adata/pml:head/pml:schema/@href 'adata_schema.xml' ;
    set $adoc/pml:adata/pml:head/pml:references/pml:reffile[@id='m']/@href
        xsh:subst($mfile, '.*/', '') ;
    rm ( $adoc//pml:is_auxiliary | $adoc//pml:is_aux_to_parent
       | $adoc//pml:is_aux_to_child | $adoc//pml:edge_to_collapse
       | $adoc//pml:parent_is_aux ) ;

    ls $mdata/head ;
    set $mdata/pml:head/pml:references/pml:reffile[@id='w']/@href
        xsh:subst($wfile, '.*/', '') ;

    for my $tree in $adoc/pml:adata/pml:trees/pml:LM {
        my $s := xinsert element pml:s into $mdata ;
        set $s/@id concat('s-', substring-after(($tree//pml:m.rf)[1], '#')) ;
        for my $a in ( $tree/pml:children/pml:LM
                     | $tree/pml:children[0 = count(pml:LM)] ) {
            split_node $a $s ;
        }
        xmove &{ sort :k pml:ord :n $s/pml:m } into $s ;
        rm $s/pml:m/pml:ord ;
        copy $s//pml:m/@id into $s//pml:w ;
        xinsert text 'w-' prepend $s//pml:w/@id ;
        xinsert element pml:w.rf into $s//pml:m ;
        xinsert text 'w#w-' prepend $s//pml:w.rf ;
        copy $s//pml:m/@id append $s//pml:w.rf/text() ;
        xmove $s//pml:w into $para ;

    }
    for $mdata//pml:tag insert attribute 'lemma=""' into . ;
    xmove :r $mdata//pml:lemma into ../pml:tag/@lemma ;
    save :b :f $afile $adoc ;
    save :f $mfile $mdoc ;
    save :f $wfile $wdoc ;
}
