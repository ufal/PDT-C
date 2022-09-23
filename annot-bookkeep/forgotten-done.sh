#! /bin/bash

# List files that exist both in done and work directories.
# Run with 'rm' as the first argument to remove them from SVN.

set -eu

action=ls
if [[ ${1:-X} = rm ]] ; then
    action=rm
fi

dir=$(readlink -f "${0%/*}")
adir=$(grep '^svn = ' "$dir"/list.cfg)
adir=${adir#svn = }


for a in "$adir"/annotators/???/wsj*.cz.a ; do
    if [[ -e ${a/wsj/done/wsj} ]] ; then
        svn "$action" "${f%a}"?
    fi
done
