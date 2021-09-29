#!/bin/bash

[ $# -ge 2 ] || { echo "Usage: $0 treebank layer files" >&2; exit 1; }

treebank="$1"; shift
layer="$1"; shift

data="$(dirname $0)/../../../$treebank/pml"
resources="$(dirname $0)/../../../../tred-extension/pdtc10/resources"

for file in "$@"; do
  treex -Lcs Read::PDT schema_dir=$resources from=$data/$file.$layer top_layer=$layer Write::CoNLLU to=conllu-$layer/$file.conllu print_zone_id=0 upos=is_parenthesis_root xpos=tag feats=is_member deprel=afun
  sed '
    1i# newdoc id = '"${file//\//-}"'
    s@^# sent_id = @# sent_id = '"${file//\//-}"'-@
  ' -i conllu-$layer/$file.conllu
  if [ "$layer" = m ]; then
    sed '
      s/^\([0-9][0-9]*\t\([^\t]*\t\)\{5\}\)0\(\(\t[^\t]*\)\{3\}\)$/\1_\3/
    ' -i conllu-$layer/$file.conllu
  fi
done
