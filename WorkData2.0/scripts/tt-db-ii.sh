#!/bin/bash
set -xv
set -eu

fail () {
    printf "%s\n" "$1" >&2
    exit 1
}

ls -d annotators/???/done > /dev/null || fail 'Wrong working directory'

prefix=db-ii-tt
rundir=$(readlink -f $0)
rundir=${rundir%/*}

if [[ ! -e "$prefix"-1.l ]] ; then
    btred -NTe 'writeln($this->{lemma} =~ s/-.*//r)
                if $this->{tag} =~ /^(?:Db|II|TT)/' \
          annotators/???/done/*.m \
        | tee "$prefix"-1.l
fi

if [[ ! -e "$prefix"-2.l ]] ; then
    sort -u "$prefix"-1.l > "$prefix"-2.l
fi


if [[ ! -e "$prefix"-3.l ]] ; then
    sed "s=__INPUT__=$prefix-2.l=" "$rundir"/tt-db-ii.btred > "$prefix-3.btred"
    btred -I "$prefix-3.btred" annotators/???/done/*.a | tee "$prefix"-3.l
fi

if [[ ! -e "$prefix"-4.l ]] ; then
    sed "s=__INPUT__=$prefix-3.l=" "$rundir"/tt-db-ii-2.btred \
        > "$prefix-4.btred"
    btred -I "$prefix-4.btred" annotators/???/done/*.t | tee "$prefix"-4.l
fi

if [[ ! -e "$prefix"-5.l ]] ; then
    sort "$prefix"-4.l \
        | uniq -c \
        | sort -k2,2 -k1,1rn \
        | awk '{print $2,$3,$4,$5,$1}' \
        | perl -pane '$l = $F[0] =~ s/-.*//r; print "\n" if $l ne $p; $p = $l' \
              > "$prefix"-5.l
fi
