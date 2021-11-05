#!/bin/bash
set -eu
shopt -s extglob

dir=$(readlink -f $0)
dir=${dir%/*}/..

for prefix ; do
    id_old=${prefix#wsj}
    n=${id_old##+(0)}
    (( id_new = n + 3000 ))
    for ext in a m t w ; do
        sed "s/$prefix/wsj$id_new/g" "$dir"/PCEDT-cz/pml/wsj"$id_old".cz.$ext \
            > "$dir"/PCEDT-cz/pml/wsj"$id_new".cz.$ext
    done
done
