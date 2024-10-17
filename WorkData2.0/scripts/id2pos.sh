#! /bin/bash
# Convert a list of ids into a list of btred file positions.

set -eu -o pipefail

if (( 0 == $# )) ; then
    echo "$0 id-list files..." >&2
    exit 1
fi

ids=$1
shift

grep -lwf "$ids" "$@" | ids=$ids btred -l- -NTe '
our %id;
BEGIN {
    open my $in, "<", $ENV{ids} or die $!;
    chomp( my @lines = <$in> );
    @id{ @lines } = ();
    use Data::Dumper; warn Dumper \%id;
}

FPosition() if exists $id{ $this->{id} };
'
