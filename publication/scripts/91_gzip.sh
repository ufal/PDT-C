#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

LOG="91_gzip.log"

mv -f $LOG $LOG.old

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust/pml; do

  echo "Gzipping files in $CORP"
  echo "Gzipping files in $CORP" >>$LOG
  for A in $BASE/$TGT/$CORP/*.w; do
    gzip $A
  done
  for A in $BASE/$TGT/$CORP/*.m; do
    sed -i 's/\.w"/.w.gz"/' $A >>$LOG
    gzip $A
  done
  for A in $BASE/$TGT/$CORP/*.a; do
    sed -i 's/\.m"/.m.gz"/' $A >>$LOG
    gzip $A
  done
  for A in $BASE/$TGT/$CORP/*.t; do
    sed -i 's/\.a"/.a.gz"/' $A >>$LOG
    gzip $A
  done

done

for CORP in Faust/treex PCEDT/treex PDTSC/treex PDT/treex/{mw,amw,tamw}/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do

  echo "Gzipping files in $CORP"
  echo "Gzipping files in $CORP" >>$LOG

  for A in $BASE/$TGT/$CORP/*.treex; do
    gzip $A
  done

done

#for CORP in Faust/mrp PCEDT/mrp PDTSC/mrp PDT/mrp/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#
#  echo "Gzipping files in $CORP"
#  echo "Gzipping files in $CORP" >>$LOG
#
#  for A in $BASE/$TGT/$CORP/*.mrp; do
#    gzip $A
#  done
#
#done

grep $LOG | sort | uniq -c

