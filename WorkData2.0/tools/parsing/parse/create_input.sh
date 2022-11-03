#!/bin/sh

[ $# -ge 1 ] || { echo Usage: $0 data_dir >&2; exit 1; }
data="$1"

find ../../../$data -name "*.a" | sed 's/\.a$//' | sort >input.files

resources="../../../../tred-extension/pdtc10/resources"
treex -Lcs Read::PDT schema_dir=$resources from=@input.files top_layer=a Write::CoNLLU to=input.conllu
