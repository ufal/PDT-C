#!/bin/bash

[ $# -ge 1 ] || { echo "Usage: $0 treebank [N]" >&2; exit 1; }
treebank="$1"
N=${2:-250}

for layer in a; do #m
  for i in $(seq 1 $N); do
    qsub -q cpu-troja.q -o /dev/null -j y bash $(dirname $0)/to_conllu.sh $treebank $layer $(split -n l/$i/$N files_$layer)
  done
done
