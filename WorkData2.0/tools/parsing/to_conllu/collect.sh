#!/bin/sh

[ $# -ge 2 ] || { echo "Usage: $0 treebank layer files" >&2; exit 1; }

treebank="$1"; shift
layer="$1"; shift

for mode in : -is_m:--is_member -is_mpr:--is_member\ --is_parenthesis_root; do
  python3 $(dirname $0)/compose_deprel.py ${mode#*:} $(for f in $(cat files_$layer); do echo conllu-$layer/$f.conllu; done) > $treebank-$layer${mode%:**}.conllu

  [ $treebank = pdt ] || continue

  for dataset in train:train dev:dtest test:etest; do
    name=${dataset%%:*}
    dir=${dataset#*:}
    python3 $(dirname $0)/compose_deprel.py ${mode#*:} conllu-$layer/*/$dir*/*.conllu | python3 $(dirname $0)/strip_lemma.py > $treebank-$layer${mode%:**}-$name.conllu
  done
done
