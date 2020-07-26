#!/usr/bin/env python3
import argparse
import sys

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=str, help="Output file path")
    args = parser.parse_args()

    entries = {}

    for line in sys.stdin:
        node, entry = line.rstrip("\n").split(maxsplit=1)
        if entry not in entries:
            entries[entry] = []
        entries[entry].append(node)

    with open(args.output, "w", encoding="utf-8") as output_file, open(args.output + ".nodes", "w", encoding="utf-8") as output_nodes_file:
        for entry, nodes in sorted(entries.items(), key=lambda x: x[0]):
            print("{:6d} {}".format(len(nodes), entry), file=output_file)
            print("{:6d} {} -> {}".format(len(nodes), entry.split(" ->")[0], " ".join(sorted(nodes))), file=output_nodes_file)
