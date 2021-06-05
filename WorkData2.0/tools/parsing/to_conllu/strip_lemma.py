#!/usr/bin/env python
import re
import fileinput

lemma_re_strip = re.compile(r"(?<=.)(?:`|_|-[^0-9]).*$")

for line in fileinput.input():
    line = line.rstrip("\n")
    parts = line.split("\t")
    if len(parts) == 10:
        parts[2] = lemma_re_strip.sub("", parts[2])
        line = "\t".join(parts)
    print(line)
