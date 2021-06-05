#!/usr/bin/env python3
import argparse

IS_MEMBER, IS_PARENTHESIS_ROOT = 5, 3

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", default=[], nargs="*", help="Input paths")
    parser.add_argument("--is_member", default=False, action="store_true", help="Add is_member")
    parser.add_argument("--is_parenthesis_root", default=False, action="store_true", help="Add is_parenthesis_root")
    args = parser.parse_args()

    for path in args.paths:
        with open(path, "r", encoding="utf-8") as conllu_file:
            for line in conllu_file:
                line = line.rstrip("\n")
                columns = line.split("\t")

                if len(columns) == 10:
                    if args.is_member and columns[IS_MEMBER] == "1":
                        columns[7] += "_IsMember"
                    columns[IS_MEMBER] = "_"

                    if args.is_parenthesis_root and columns[IS_PARENTHESIS_ROOT] == "1":
                        columns[7] += "_IsParenthesisRoot"
                    columns[IS_PARENTHESIS_ROOT] = "_"

                    line = "\t".join(columns)

                print(line)
