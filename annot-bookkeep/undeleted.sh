#!/bin/bash

# Some files were taken away from annotators, but they continue
# working on them. This should list all the "done" files that belong
# to someone else.

dir=$(readlink -f "${0%/*}")
svn=$(grep '^svn = ' "$dir"/list.cfg | cut -d' ' -f3)

cut -f1,4 "$dir"/list.txt \
| perl -lane 'print "$F[1].*$F[0]"' \
| grep -vf- <(ls "$svn"/annotators/???/done/wsj*.a) \
| rev | cut -d/ -f1 | rev \
| sort \
| cut -d. -f1 \
| grep -Ff- "$dir"/list.txt \
| grep -vE 'ALL|learn|lrec|train|mam'
