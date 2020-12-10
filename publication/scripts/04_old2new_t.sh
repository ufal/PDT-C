#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

LOG="04_old2new_t.log"
SUM="04_old2new_t.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

for CORP in Faust PCEDT PDTSC; do

  echo "Updating t-data format in $CORP/pml"
  echo "Updating t-data format in $CORP/pml" >>$LOG
  btred -I 04_old2new_t.btred $BASE/$TGT/$CORP/pml/*.t >>$LOG 2>&1

done

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do

  sed -i "s/tdata_c_schema_work.xml/tdata_c_schema.xml/" $BASE/$TGT/$CORP/*.t
  grep "<schema" $BASE/$TGT/$CORP/*.t | cut -f 2 -d ":" >>$LOG

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM


