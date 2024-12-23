#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

LOG="03_old2new_m.log"
SUM="03_old2new_m.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust/pml; do

  echo "Updating m-data format in $CORP"
  echo "Updating m-data format in $CORP" >>$LOG
  btred -I 03_old2new_m.btred $BASE/$TGT/$CORP/*.m >>$LOG 2>&1

  sed -i "s/mdata_c_schema_work.xml/mdata_c_schema.xml/" $BASE/$TGT/$CORP/*.m

  grep "<schema" $BASE/$TGT/$CORP/*.m | cut -f 2 -d ":" >>$LOG

done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM

