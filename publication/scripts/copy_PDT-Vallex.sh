#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

SRC="tred-extension/pdt_c_m/resources"
TGT="publication/PDT_C/data/PDT-Vallex"

rm -rf $BASE/$TGT/vallex3.xml

echo "Copying PDT-Vallex"

cp $BASE/$SRC/vallex3.xml $BASE/$TGT/vallex3.xml
