#!/bin/sh

set -e

morfflex=/net/projects/morfflex/cz/compiled/czech-morfflex-pdt-c/czech-morfflex-pdt-c

mkdir -p PDT-C
rm PDT-C/*

exec >PDT-C/pdt-c.log 2>&1
echo Running checks at `date`

echo Copying current MorhoDiTa dictionary

cp $morfflex.dict PDT-C/
grep '^Resense' $morfflex.log >PDT-C/morpho.resensing.txt
grep '^Removing comment' $morfflex.log >PDT-C/morpho.semco_merging.txt
grep '^Removing style' $morfflex.log >PDT-C/morpho.style_merging.txt
grep '^Possible' $morfflex.log >PDT-C/morpho.0derivation.txt

echo Updating PDT-C repository from GitHub
git pull https://github.com/ufal/PDT-C

echo Running the checks
python3 pdtc_to_vertical.py `find ../../../[FP]* -name "*.m" | sort` >PDT-C/pdt-c.tsv
TSV_VALID=1 sh consistency_vertical_run.sh $morfflex.dict morpho.resensing.txt
TSV_VALID=1 sh correct_lemmas_run.sh
sh correct_morpho_run.sh $morfflex.raw.xz >PDT-C/morpho.correctness.txt

echo All ok
