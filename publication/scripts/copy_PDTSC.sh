#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

SRC="WorkData/PDTSC/data"
TGT="publication/PDT_C/data/PDTSC"

rm -rf $BASE/$TGT/*.[wmat]

echo "Copying PDTSC w-files"

for A in $BASE/$SRC/*.w; do
  B="$(basename -- $A)"
  cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying PDTSC m-files"

for A in $BASE/$SRC/*.m; do
  B="$(basename -- $A)"
  cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying PDTSC a-files"

for A in $BASE/$SRC/*.a; do
  B="$(basename -- $A)"
  cat $A | sed "s/adata_.*schema.xml/adata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying PDTSC t-files"

for A in $BASE/$SRC/*.t; do
  B="$(basename -- $A)"
  cat $A | sed "s/tanot_coref_schema.xml/tdata_c_schema_work.xml/" >$BASE/$TGT/$B
done
