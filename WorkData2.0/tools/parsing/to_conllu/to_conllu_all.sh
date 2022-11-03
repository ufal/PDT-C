#!/bin/bash

[ $# -ge 1 ] || { echo "Usage: $0 treebank [N]" >&2; exit 1; }
treebank="$1"
N=${2:-200}

for layer in a; do #m
  for i in $(seq 1 $N); do
    sbatch -p cpu-ms run bash $(dirname $0)/to_conllu.sh $treebank $layer $(split -n l/$i/$N files_$layer)
  done
done
