#!/bin/bash

BASE="/net/work/projects/PDT-C"

TGT="PEDT_svn_wsj"

VALLEX="github-PDT-C/publication/PCEDT-3.0/data/dictionaries/engvallex.xml"

LOG="55_check_engvallex.log"
SUM="55_check_engvallex.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

CORP="PCEDT-en"

echo "Checking links to EngVallex in $CORP"
echo "Checking links to EngVallex in $CORP" >>$LOG
btred -I 05_check_vallex.btred $BASE/$TGT/*/*.t.gz >>$LOG 2>&1 -o $BASE/$VALLEX --

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM

