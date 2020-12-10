#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT-C/data"

#for A in Faust/pml PCEDT/pml PDT/pml PDTSC/pml dictionaries; do
for A in Faust/pml PCEDT/pml PDT/pml PDTSC/pml; do
  echo "Clearing $TGT/$A"
  rm -rf $BASE/$TGT/$A/*
done

