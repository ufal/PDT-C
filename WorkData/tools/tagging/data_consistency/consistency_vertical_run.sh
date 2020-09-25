#!/bin/sh

[ $# -ge 1 ] || { echo Usage: $0 path_to_MorphoDiTa_dict >&2; exit 1; }
[ -f "$1" ] || { echo The given dictionary "'$1'" is not a file >&2; exit 1; }

mkdir -p PDT-C
cd PDT-C
[ -n "$TSV_VALID" ] || python3 ../pdtc_to_vertical.py `find ../../../../[FP]* -name "*.m" | sort` >pdt-c.tsv
perl ../consistency_vertical.pl "$@" <pdt-c.tsv >pdt-c.consistency-overview.txt

(
  echo
  echo "Error_type Number_of_error_classes Number_of_error_instances"
  for f in multiple*.txt no_analysis*.txt unique*.txt; do
    echo -n "${f%.txt} "
    awk '{print $1}' $f | st -nh -N -s
  done
) | column -ent >>pdt-c.consistency-overview.txt
