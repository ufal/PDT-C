#!/bin/sh

for layer in a; do #m
  for mode in : -is_m:--is_member -is_mpr:--is_member\ --is_parenthesis_root; do
    python3 compose_deprel.py ${mode#*:} $(for f in $(cat files_$layer); do echo conllu-$layer/$f.conllu; done) > pdtc-1-$layer${mode%:**}.conllu

    for dataset in train:train dev:dtest test:etest; do
      name=${dataset%%:*}
      dir=${dataset#*:}
      python3 compose_deprel.py ${mode#*:} conllu-$layer/*/$dir*/*.conllu | python3 strip_lemma.py > pdtc-1-$layer${mode%:**}-$name.conllu
    done
  done
done
