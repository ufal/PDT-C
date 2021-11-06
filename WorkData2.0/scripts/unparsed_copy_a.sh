#!/bin/bash

# Send prefixes like wsj1234 as parameters. The script will create
# copies of them, remove any a-layer annotation, and rename them by
# adding 3000 to their names.

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
btred -STe 'CutPaste($_, $root) for $root->descendants' "$dir"/PCEDT-cz/pml/wsj[345]???.cz.a
btred -SNTe '$this->{afun} = "ExD"' "$dir"/PCEDT-cz/pml/wsj[345]???.cz.a
sed -i~ '/<is_/d' WorkData2.0/PCEDT-cz/pml/wsj[345]???.cz.a
