#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PDT_C/data"

for A in Faust PCEDT PDT PDTSC PDT-Vallex; do
  echo "Clearing $TGT/$A"
  rm -rf $BASE/$TGT/$A/*
done

