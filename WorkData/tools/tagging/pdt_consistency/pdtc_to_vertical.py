#!/usr/bin/env python3
import argparse
import xml.etree.ElementTree
import sys

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+", type=str, help="Files to process")
    args = parser.parse_args()

    for path in args.paths:
        form, recommended, selected, alls = None, None, None, []
        with open(path, "r", encoding="utf-8") as path_file:
            for line in path_file:
                if line.startswith("<form>"):
                    form = xml.etree.ElementTree.fromstring(line).text

                if line.startswith(("<AM", "<tag ")):
                    suffix = "</tag>\n" if line.startswith("<AM") and line.endswith("</tag>\n") else "\n"
                    element = xml.etree.ElementTree.fromstring(line[:-len(suffix)])
                    alls.append((element.get("lemma"), element.text))
                    if element.get("selected") is not None:
                        selected = alls[-1]
                    if element.get("recommended") is not None:
                        recommended = alls[-1]

                if "</tag" in line:
                    assert form is not None
                    if recommended is None and selected is None and len(alls) == 1:
                        recommended = alls[0]
                    if recommended is None and selected is None:
                        print("Missing recommended and selected for {}, {} analyses, skipping".format(form, len(alls)), file=sys.stderr)
                    else:
                        lemma, tag = selected if selected is not None else recommended
                        print(form, lemma, tag, sep="\t")

                    form, recommended, selected, alls = None, None, None, []
