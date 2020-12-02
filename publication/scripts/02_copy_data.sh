#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

SRC="WorkData/Faust/data"
TGT="publication/PDT-C/data/Faust/pml"

rm -rf $BASE/$TGT/*.[wmat]

echo "Copying Faust w-files"

for A in $BASE/$SRC/*.w; do
  B="$(basename -- $A)"
  cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying Faust m-files"

for A in $BASE/$SRC/*.m; do
  B="$(basename -- $A)"
  cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema_work.xml/" | sed 's/<tag/<mtag/' | sed 's/<\/tag>/<\/mtag>/' >$BASE/$TGT/$B
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




SRC="WorkData/PCEDT/data"
TGT="publication/PDT-C/data/PCEDT/pml"

rm -rf $BASE/$TGT/*.[wmat]

echo "Copying PCEDT w-files"

for A in $BASE/$SRC/*.w; do
  B="$(basename -- $A)"
  cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying PCEDT m-files"

for A in $BASE/$SRC/*.m; do
  B="$(basename -- $A)"
  cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema_work.xml/" | sed 's/<tag/<mtag/' | sed 's/<\/tag>/<\/mtag>/' >$BASE/$TGT/$B
done

echo "Copying PCEDT a-files"

for A in $BASE/$SRC/*.a; do
  B="$(basename -- $A)"
  cat $A | sed "s/adata_.*schema.xml/adata_c_schema.xml/" | sed "s/aanot_schema.xml/adata_c_schema.xml/" | sed "/eng_sentence/d" >$BASE/$TGT/$B
done

echo "Copying PCEDT t-files"

for A in $BASE/$SRC/*.t; do
  B="$(basename -- $A)"
  cat $A | sed "s/tanot_schema.xml/tdata_c_schema_work.xml/" >$BASE/$TGT/$B
done



SRC_VAL="$BASE/tred-extension/pdt_c_m/resources"
SRC_ENG_VAL="/net/data/pcedt2.0/valency_lexicons"
TGT="publication/PDT-C/data/dictionaries"

rm -rf $BASE/$TGT/pdtvallex10.xml
echo "Copying PDT-Vallex"
cp $SRC_VAL/vallex3.xml $BASE/$TGT/pdtvallex10.xml

rm -rf $BASE/$TGT/engvallex.xml
echo "Copying EngVallex"
cp $SRC_ENG_VAL/engvallex.xml $BASE/$TGT/engvallex.xml



SRC="WorkData/PDT/data"
TGT="publication/PDT-C/data/PDT/pml"

echo "Copying PDT data"

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
      cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema_work.xml/" | sed 's/<tag/<mtag/' | sed 's/<\/tag>/<\/mtag>/' >$BASE/$TGT/$SET/$PART/$B
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




SRC="WorkData/PDTSC/data"
TGT="publication/PDT-C/data/PDTSC/pml"

rm -rf $BASE/$TGT/*.[wmat]

echo "Copying PDTSC w-files"

for A in $BASE/$SRC/*.w; do
  B="$(basename -- $A)"
  cat $A | sed "s/wdata_.*schema.xml/wdata_c_schema.xml/" >$BASE/$TGT/$B
done

echo "Copying PDTSC m-files"

for A in $BASE/$SRC/*.m; do
  B="$(basename -- $A)"
  cat $A | sed "s/mdata_.*schema.xml/mdata_c_schema_work.xml/" | sed 's/<tag/<mtag/' | sed 's/<\/tag>/<\/mtag>/' >$BASE/$TGT/$B
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
