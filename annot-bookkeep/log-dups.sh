#!/bin/bash
dir=$(readlink -f "${0%/*}")
svn=$(grep '^svn = ' "$dir"/list.cfg | cut -d' ' -f3)

cut -f1,4 "$dir"/list.txt |
    sed -E 's=(.*)\t(.*)=\2/done/\1.cz.a=' |
    grep -vFf- <(ls "$svn"/annotators/???/done/*.a) |
    while read a ; do
        w=${a%.cz.a}
        w=${w##*/}
        printf '%s\t%s\n' "$a" "$(grep "$w" "$dir"/list.txt)"
    done |
    cut -f1,5,8 |
    grep ALL | grep -vE 'learn|training' |
    cut -f1,3 |
    while read a w ; do
        annot=$(grep -o '.../done/wsj'  <<< "$a" | cut -d/ -f1)
        grep "wsj$w.*$annot" "$dir"/list.txt |
            sed "s=^=$a\t="
    done |
    cut -f1,2,5 |
    while read a w annot ; do
        date=$(svn log "$a" | grep -om1 '202.-..-..')
        date=${date//-}
        echo "/$w.*$annot/s/\t\t/\t${date#20}\t/"
    done |
    sed -f- "$dir"/list.txt
