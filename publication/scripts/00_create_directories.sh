#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

for A in Faust/pml PCEDT/pml PDT/pml PDTSC/pml dictionaries; do
  echo "Creating directory $TGT/$A"
  mkdir -p $BASE/$TGT/$A
done

