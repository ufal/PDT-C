#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

SRC="WorkData/PDT/data"
TGT="publication/PDT_C/data/PDT"

rm -rf $BASE/$TGT/*mw/*
rmdir $BASE/$TGT/*mw

for PART in train-1 train-2 train-3 train-4 train-5 train-6 train-7 train-8 dtest etest; do

  for SET in mw amw tamw; do

    mkdir -p $BASE/$TGT/$SET/$PART

    for A in $BASE/$SRC/$SET/$PART/*.w; do
      B="$(basename -- $A)"
      cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$SET/$PART/$B
    done

    for A in $BASE/$SRC/$SET/$PART/*.m; do
      B="$(basename -- $A)"
      cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema.xml/" >$BASE/$TGT/$SET/$PART/$B
    done

  done

  for SET in amw tamw; do

    mkdir -p $BASE/$TGT/$SET/$PART

    for A in $BASE/$SRC/$SET/$PART/*.a; do
      B="$(basename -- $A)"
      cat $A | sed "s/adata_.*schema.xml/adata_c_schema.xml/" >$BASE/$TGT/$SET/$PART/$B
    done

  done

  mkdir -p $BASE/$TGT/tamw/$PART

  for A in $BASE/$SRC/tamw/$PART/*.t; do
    B="$(basename -- $A)"
    cat $A | sed "s/tdata_.*schema.xml/tdata_c_schema_work.xml/" >$BASE/$TGT/tamw/$PART/$B
  done

done
