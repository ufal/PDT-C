#!/bin/bash

BASE="/net/work/projects/PDT-C"

TGT="PEDT_svn_wsj"

LOG="56_check_internal_links.log"
SUM="56_check_internal_links.summary"

mv -f $LOG $LOG.old
mv -f $SUM $SUM.old

CORP="PCEDT-en"

echo "Checking internal links in $CORP"
echo "Checking internal links in $CORP" >>$LOG
btred -I 56_check_internal_links.btred $BASE/$TGT/*/*.t.gz >>$LOG 2>&1
#btred -I 56_check_p_links.btred $BASE/$TGT/*/*.a.gz >>$LOG 2>&1

grep -v Saving $LOG | grep -v Processing | grep -v PDTB | grep -v PMLTQ | grep -v Subroutine | grep -v Applying | grep -v Initializing | cut -f 1,2,3 -d " " | sort | uniq -c | tee $SUM

