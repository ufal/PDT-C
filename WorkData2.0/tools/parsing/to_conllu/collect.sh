#!/bin/sh

for layer in a; do #m
  for dataset in train:train dev:dtest test:etest; do
    name=${dataset%%:*}
    dir=${dataset#*:}

    for mode in : -is_m:--is_member -is_mpr:--is_member\ --is_parenthesis_root; do
      python3 compose_deprel.py ${mode#*:} conllu-$layer/*/$dir*/*.conllu > pdtc-1-$layer${mode%:**}-$name.conllu
    done
  done
done
