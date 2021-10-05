#!/usr/bin/env python3
import argparse
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=str, help="Input path")
    args = parser.parse_args()

    with open("files_a", "r", encoding="utf-8") as filelist_file:
        test = [line.rstrip("\n") for line in filelist_file.readlines()]

    printing = False
    with open(args.input, "r", encoding="utf-8") as input_file:
        for line in input_file:
            line = line.rstrip("\n")
            if line.startswith("# newdoc id ="):
                printing = line.split()[-1] in test

            if printing:
                print(line)

