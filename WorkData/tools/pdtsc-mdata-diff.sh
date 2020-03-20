#!/bin/bash
wfiles=$1
mdata=$2

diff -uw \
     <(grep '<form' WorkData/PDTSC/data/$mdata.mdata | sed 's/<[^>]*>//g') \
     <(grep -h '<token' WorkData/PDTSC/data/$wfiles.*.w  | sed 's/<[^>]*>//g')
