#!/bin/bash
mfiles=$1
mdata=$2

echo $mfiles $mdata
diff -uw \
     <(grep '<form' WorkData/PDTSC/data/$mdata.mdata | sed 's/ *<[^>]*>//g') \
     <(grep -h '<form[^_]' WorkData/PDTSC/data/$mfiles.*.m  | sed 's/<[^>]*>//g')
