#! /bin/bash
# Replace [wmt] files with the original ones, the changes in them are random.

set -eu

dir=$(readlink -f "${0%/*}")
adir=$(grep '^svn = ' "$dir"/../../annot-bookkeep/list.cfg)
adir=${adir#svn = }

for f in "$adir"/annotators/???/done/wsj????.cz.[mtw] ; do
    printf '%s\r' "${f##*/}"
    cp "$dir"/../PCEDT-cz/pml/"${f##*/}" "$f"
done
