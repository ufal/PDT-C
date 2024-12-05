#!/bin/bash

# Resave files modified in SVN with a different backend configuration to
# minimise the diff size. Before running this script, tweak pmlbackend.conf to
# correspond to the config used to save the modified files.

set -eu -o pipefail

main () {
    local line
    local changed=0
    local stayed=0
    local skip=0
    local file
    while IFS= read -r line ; do
        if ((skip)) ; then
            ((skip--))
            continue
        fi

        if [[ $line = Index:\ * ]] ; then
            echo $changed $stayed
            if ((changed > stayed)) ; then
                btred -Se1 "$file"
                if [[ $file = *.t ]] ; then
                    svn revert "${file%.t}".a
                fi
                svn diff "$file"
            fi

            file=${line#* }
            echo "$file"
            changed=0 || :
            stayed=0 || :
            skip=3
        elif [[ $line = [-+]* ]] ; then
            ((++changed))
        elif [[ $line = ' '* ]] ; then
            ((++stayed))
        fi

    done < <(svn diff ; echo Index: === DONE ===)
}

main
