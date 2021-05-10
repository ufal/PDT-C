#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="WorkData2.0"

LOG="00_unindent.log"
SUM="00_unindent.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old


#for CORP in PCEDT-cz/pml PDTSC/pml Faust/pml PDT/pml/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
for CORP in PDT/pml/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do

  echo "Unindenting files in $CORP" | tee $LOG
  btred --resource-dir resources_unindent -K ALL -e "ChangingFile();" $BASE/$TGT/$CORP/*.[tam] >>$LOG 2>&1
  rm $BASE/$TGT/$CORP/*~

done

grep -v Saving $LOG |\
  grep -v Processing |\
  grep -v PDTB |\
  grep -v PMLTQ |\
  grep -v Subroutine |\
  grep -v Applying |\
  grep -v Initializing |\
  cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM

