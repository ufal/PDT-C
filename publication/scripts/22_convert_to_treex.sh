#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

WD=`pwd`

LOG="$WD/22_convert_to_treex.log"

mv -f $LOG $LOG.old

for CORP in Faust/pml PCEDT/pml PDTSC/pml PDT/pml/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}; do
#for CORP in Faust/pml; do

  cd $BASE/$TGT/$CORP
  echo "Converting PDT data to treex in $CORP"
  echo "Converting PDT data to treex in $CORP" >>$LOG
  treex -Lcs Read::PDT version='3.0' from='!*.t' Write::Treex to=. substitute={}{../treex/} >>$LOG 2>&1
  cd $WD

done


