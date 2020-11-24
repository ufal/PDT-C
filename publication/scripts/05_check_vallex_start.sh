#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

VALLEX="publication/PDT_C/data/PDT-Vallex/vallex3.xml"

LOG="05_check_vallex.log"

mv -f $LOG $LOG.old

for CORP in Faust PCEDT PDTSC PDT/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust; do

  echo "Checking links to Vallex in $CORP"
  echo "Checking links to Vallex in $CORP" >>$LOG
  btred -I 05_check_vallex.btred $BASE/$TGT/$CORP/*.t >>$LOG 2>&1 -o $BASE/$VALLEX --

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | cut -f 1,2,3 -d " " | sort | uniq -c

