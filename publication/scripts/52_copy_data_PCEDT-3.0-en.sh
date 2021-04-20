#!/bin/bash

BASE="/net/work/projects/PDT-C"

LOG="52_copy_data_PCEDT-3.0-en.log"
SUM="52_copy_data_PCEDT-3.0-en.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

SRC="PEDT_svn_wsj"
TGT="github-PDT-C/publication/PCEDT-3.0/data/en/pml"

rm -rf $BASE/$TGT/*.t
rm -rf $BASE/$TGT/*.[wma].gz

echo "Copying PCEDT-3.0-en p-files"

for A in $BASE/$SRC/*/*.p.gz; do
  B="$(basename -- $A)"
  cp $A $BASE/$TGT/$B
done

echo "Copying PCEDT-3.0-en a-files"

for A in $BASE/$SRC/*/*.a.gz; do
  B="$(basename -- $A)"
  cp $A $BASE/$TGT/$B
done

echo "Copying PCEDT-3.0-en t-files"

for A in $BASE/$SRC/*/*.t; do
  B="$(basename -- $A)"
  cat $A | sed "/<gram\/>/d" | sed "/<a\/>/d" >$BASE/$TGT/$B
done

cat $LOG | sort | uniq -c | tee $SUM
