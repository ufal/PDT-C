#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

mv -f old2new.log old2new.log.old

for CORP in Faust PCEDT PDTSC; do

  echo "Updating data format in $CORP" | tee >>old2new.log
  btred -I old2new.btred $BASE/$TGT/$CORP/*.t >>old2new.log 2>&1

done

grep -v Saving old2new.log| grep -v Processing | cut -f 1,2,3 -d " " | sort | uniq -c


