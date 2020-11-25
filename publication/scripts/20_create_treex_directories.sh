#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

for A in Faust/treex PCEDT/treex PDT/treex PDTSC/treex; do
  echo "Creating directory $TGT/$A"
  mkdir -p $BASE/$TGT/$A
done

