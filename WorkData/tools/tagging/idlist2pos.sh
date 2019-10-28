#! /bin/bash
idlist=$1
shift

regex=$(perl -pe 'chomp;substr$_,0,0,"|"unless$.==1' < "$idlist")

btred -NTe 'print($this->{id}, "\t"), FPosition() if $this->{id} =~ /^(?:'"$regex"')$/' "$@"

