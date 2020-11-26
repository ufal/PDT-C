#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

LOG="06_check_internal_links.log"

mv -f $LOG $LOG.old

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust/pml; do

  echo "Checking internal links in $CORP"
  echo "Checking internal links in $CORP" >>$LOG
  btred -I 06_check_internal_links.btred $BASE/$TGT/$CORP/*.t >>$LOG 2>&1

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c

