#!/bin/bash
set -eu

function main () {
    local dir=$1
    local p
    for p in "$dir"/*.p/ ; do
        local selected=$(
            grep -c 'selected=' "$p"*.m |
                sort -R | head -n1 | cut -d: -f1)
        echo "$selected" >&2
        local m=${p%.p/}.m
        mv "$selected" "$m"
        sed -i 's,href="\.\./,href=",' "$m"
    done
}

main "$@"
