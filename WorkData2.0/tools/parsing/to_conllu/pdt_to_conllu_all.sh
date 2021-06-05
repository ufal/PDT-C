#!/bin/bash

N=250

for layer in a; do #m
  for i in $(seq 1 $N); do
    qsub -q cpu-troja.q -o /dev/null -j y bash pdt_to_conllu.sh $layer $(split -n l/$i/$N files_$layer)
  done
done
