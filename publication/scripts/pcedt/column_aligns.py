import sys
import argparse

parser = argparse.ArgumentParser(description="A script to split alignment links into columns by their type")
parser.add_argument("colstr", type=str, help="_-delimited string of column names to print")
args = parser.parse_args()

column_names = args.colstr.split("_")

for line in sys.stdin:
    line = line.rstrip()
    aligns_by_type = {}
    aligns = line.split(" ")
    for align in aligns:
        a, t = align.split(":")
        aligns_by_type.setdefault(t, []).append(a)
    print("\t".join([" ".join(aligns_by_type.get(colname, [])) for colname in column_names]))
