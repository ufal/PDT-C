#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

SRC="WorkData/Faust/data"
TGT="publication/PDT_C/data/Faust"

rm -rf $BASE/$TGT/*.[wmat]

echo "Copying Faust w-files"

for A in $BASE/$SRC/*.w; do
  B="$(basename -- $A)"
  cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying Faust m-files"

for A in $BASE/$SRC/*.m; do
  B="$(basename -- $A)"
  cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying Faust a-files"

for A in $BASE/$SRC/*.a; do
  B="$(basename -- $A)"
  cat $A | sed "s/adata_.*schema.xml/adata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying Faust t-files"

for A in $BASE/$SRC/*.t; do
  B="$(basename -- $A)"
  cat $A | sed "s/tdata_.*schema.xml/tdata_c_schema_work.xml/" >$BASE/$TGT/$B
done
