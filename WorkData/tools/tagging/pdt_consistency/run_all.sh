#!/bin/sh

[ $# -ge 1 ] || { echo Usage: $0 path_to_MorphoDiTa_dict >&2; exit 1; }
[ -f "$1" ] || { echo The given dictionary "'$1'" is not a file >&2; exit 1; }

for d in Faust PCEDT PDT PDTSC; do
  mkdir -p $d
  (
    cd $d && python3 ../pdtc_to_vertical.py `find ../../../../$d -name "*.m"` >$d.tsv
    perl ../consistency_vertical.pl "$1" $d.tsv >$d.tsv.log
  ) &
done
wait
