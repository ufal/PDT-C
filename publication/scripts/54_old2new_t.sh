#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PCEDT-3.0/data/en"

LOG="54_old2new_t.log"
SUM="54_old2new_t.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

echo "Updating t-data format in $BASE/$TGT/pml"
echo "Updating t-data format in $BASE/$TGT/pml" >>$LOG
btred -I 54_old2new_t.btred $BASE/$TGT/pml/*.t >>$LOG 2>&1

echo "Removing empty <a/>"
for A in $BASE/$TGT/pml/*.t; do
  sed -i "/<a\/>/d" $A
done

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM
