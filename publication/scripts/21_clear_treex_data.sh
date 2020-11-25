#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

for A in Faust/treex PCEDT/treex PDT/treex PDTSC/treex; do
  echo "Clearing $TGT/$A"
  rm -rf $BASE/$TGT/$A/*
done

