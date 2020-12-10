#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

VALLEX="publication/PDT-C/data/dictionaries/pdtvallex-2.0.xml"

LOG="05_check_vallex.log"
SUM="05_check_vallex.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust/pml; do

  echo "Checking links to Vallex in $CORP"
  echo "Checking links to Vallex in $CORP" >>$LOG
  btred -I 05_check_vallex.btred $BASE/$TGT/$CORP/*.t >>$LOG 2>&1 -o $BASE/$VALLEX --

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM

