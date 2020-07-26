#!/bin/sh

[ $# -ge 1 ] || { echo Usage: $0 path_to_morfflex.raw.xz >&2; exit 1; }
[ -f "$1" ] || { echo The given dictionary "'$1'" is not a file >&2; exit 1; }

xzcat "$1" | python3 correct_morpho.py | sort | uniq -c
