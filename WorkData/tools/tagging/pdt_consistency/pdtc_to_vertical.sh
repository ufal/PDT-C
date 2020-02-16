#!/bin/sh

for d in Faust PCEDT PDT PDTSC; do
  python3 pdtc_to_vertical.py `find ../../../$d -name "*.m"` >$d.tsv &
done
wait
