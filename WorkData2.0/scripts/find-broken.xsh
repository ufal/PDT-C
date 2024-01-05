# If the PML is broken in a t-file, run this script on it. It
# generates a series of t-files each containing a single tree. Then
# run "btred -e1" on them to find which tree was broken.
# The trees have the tree id appended to their name.

my $name = { $ARGV[0] } ;
my $o := open $name ;

for my $tree in $o/pml:tdata/pml:trees/pml:LM {
    my $c := create root ;
    xcopy $o/pml:tdata replace $c/root ;
    rm $c/pml:tdata/pml:trees/pml:LM[not(@id = $tree/@id)] ;
    save :f concat($name, $tree/@id) $c ;
}
