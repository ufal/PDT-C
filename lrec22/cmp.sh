#! /bin/bash
set -eu

total=$(wc -l < lrec/mam.v)

declare -A type
type=([UAS]=1,2 [LAS]=1,2,4 [FULL]=1,2,4-7)

for t in UAS LAS FULL ; do
    printf '\n\n%s\n' $t
    for a1 in bas jah mam toh gold ; do
        for a2 in bas jah mam toh gold ; do
            [[ $a1 < $a2 ]] || continue

            same=$(comm -12 <(cut -f${type[$t]} lrec/"$a1".v) \
                            <(cut -f${type[$t]} lrec/"$a2".v) | wc -l)
            printf "%s %s:\t" $a1 $a2
            bc -l <<< "100 * $same/$total"
        done
    done # | sort -nk3
done > cmp
gnuplot <<'EOF' > cmp.png
set key outside
set xrange [0:11]
set term png
set xtics ('bj' 1, 'bm' 2, 'bt' 3, 'bg' 4, 'jm' 5, 'jt' 6, 'mt' 7, 'gj' 8, 'gm' 9, 'gt' 10)
plot 'cmp' u($3) index 0 title 'uas', '' u($3) index 1 title 'las', '' u($3) index 2 title 'full'
EOF
