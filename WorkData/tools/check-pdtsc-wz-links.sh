#!/bin/bash
for wdata in WorkData/PDTSC/data/*.wdata ; do
    zdata=WorkData/PDTSC/data/$(
        xmllint --xpath '//*[local-name()="reffile"][@name="zdata"]/@href' \
                "$wdata" | cut -f2 -d\")
    missing=$(comm -13 <(grep -o 'id="[^"]*"' "$zdata" | cut -f2 -d\" \
                         | sort -u) \
                       <(sed -n '/<z\.rf/,/<\/z\.rf/p' "$wdata" | grep LM \
                         | sed 's/.*#\(.*\)<\/LM>/\1/' | sort -u) \
              | wc -l)
    if ((missing)) ; then
        printf '%s\t%d\n' "${wdata%.wdata}" "$missing"
    fi
done
