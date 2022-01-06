#! /bin/bash
set -eu

count () {
    grep -hE "$1" *.v | cut -f1 | sort | uniq -c | sort -n | wc -l
}

declare -A regex
regex=([tr]='wsj(0282|1455)'
       [rules]='wsj(0989|1446)'
       [tr_rules]='wsj1(568|986)'
       [no_supp]='wsj(1002|2250)')

declare -A struct
struct=([parsed]='MST parser'
        [manual]='Not parsed')

declare -A columns
columns=([UAS]=1,5 [LAS]=1,5,7 [FULL]=1,5,7-10)

cd lrec


echo Checking numbers of sentences. >&2

[[ $(count "${regex[tr]}")       -eq $((1252 + 1258)) ]]
[[ $(count "${regex[rules]}")    -eq $((1257 + 1254)) ]]
[[ $(count "${regex[tr_rules]}") -eq $((1262 + 1239)) ]]
[[ $(count "${regex[no_supp]}")  -eq $((1261 + 1241)) ]]
[[ $(count "${struct[parsed]}")   -eq $((1261 + 1241 + 1252 + 1258 + 1257 + 1254 + 1262 + 1239)) ]]
[[ $(count "${struct[manual]}")   -eq $((1261 + 1241 + 1252 + 1258 + 1257 + 1254 + 1262 + 1239)) ]]


for score in UAS LAS FULL ; do
    echo "$score"
    for type in "${!regex[@]}" ; do
        for anot in ??? ; do
            for parsed in "${!struct[@]}" ; do
                selected=$(grep -hE "${regex[$type]}" $anot.v | grep "${struct[$parsed]}")
                total=$(wc -l <<< "$selected")
                same=$(comm -12 <(cut -f"${columns[$score]}" <<< "$selected" | sort) \
                                <(grep -hE "${regex[$type]}" gold.v | cut -f"${columns[$score]}" | sort) | wc -l)
                if (( ! same )) ; then continue ; fi
                printf '%-8s %3s %6s ' "$type" "$anot" "$parsed"
                echo "100*$same/$total" | bc -l
            done
        done
    done
done




exit

gnuplot <<'EOF' > cmp.png
set key outside
set xrange [0:11]
set term png
set xtics ('bj' 1, 'bm' 2, 'bt' 3, 'bg' 4, 'jm' 5, 'jt' 6, 'mt' 7, 'gj' 8, 'gm' 9, 'gt' 10)
plot 'cmp' u($3) index 0 title 'uas', '' u($3) index 1 title 'las', '' u($3) index 2 title 'full'
EOF
