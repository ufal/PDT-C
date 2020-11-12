#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

mv -f old2new_t.log old2new_t.log.old

for CORP in Faust PCEDT PDTSC; do

  echo "Updating t-data format in $CORP"
  echo "Updating t-data format in $CORP" >>old2new_t.log
  btred -I old2new_t.btred $BASE/$TGT/$CORP/*.t >>old2new_t.log 2>&1

done

grep -v Saving old2new_t.log| grep -v Processing | cut -f 1,2,3 -d " " | sort | uniq -c

