#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

LOG="04_old2new_t.log"

mv -f $LOG $LOG.old

for CORP in Faust PCEDT PDTSC; do

  echo "Updating t-data format in $CORP"
  echo "Updating t-data format in $CORP" >>$LOG
  btred -I 04_old2new_t.btred $BASE/$TGT/$CORP/*.t >>$LOG 2>&1

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | cut -f 1,2,3 -d " " | sort | uniq -c

