#!/bin/bash

BASE="/net/work/projects/PDT-C/github-PDT-C"

TGT="publication/PCEDT-3.0/data"

for A in en/pml; do
  echo "Clearing $TGT/$A"
  rm -rf $BASE/$TGT/$A/*
done

