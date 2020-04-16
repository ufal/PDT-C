#!/bin/sh

for d in Faust PCEDT PDT PDTSC; do
  mkdir -p $d
  (
    cd $d
    [ -n "$TSV_VALID" ] || python3 ../pdtc_to_vertical.py `find ../../../../$d -name "*.m"` >$d.tsv
    python3 ../correct_lemmas.py $d.tsv | sort | uniq -c >$d.correctness.log
  ) &
done
wait
