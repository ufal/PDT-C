#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

mv -f old2new_m.log old2new_m.log.old

#for CORP in Faust PCEDT PDTSC PDT/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
for CORP in Faust; do

  echo "Updating m-data format in $CORP"
  echo "Updating m-data format in $CORP" >>old2new_m.log
  btred -I old2new_m.btred $BASE/$TGT/$CORP/*.m >>old2new_m.log 2>&1

done

grep -v Saving old2new_m.log| grep -v Processing | cut -f 1,2,3 -d " " | sort | uniq -c

