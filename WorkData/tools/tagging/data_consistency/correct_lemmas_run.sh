#!/bin/sh

mkdir -p PDT-C
cd PDT-C
[ -n "$TSV_VALID" ] || python3 ../pdtc_to_vertical.py `find ../../../../[FP]* -name "*.m" | sort` >pdt-c.tsv
python3 ../correct_lemmas.py pdt-c.tsv | python3 ../correct_lemmas_grouper.py pdt-c.correctness.txt
