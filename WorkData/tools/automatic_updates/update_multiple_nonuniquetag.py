#!/usr/bin/env python3
import argparse
import re
import sys
import xml.etree.ElementTree

class Rules:
    def __init__(self, rules_path):
        self._rules = {}
        self.not_found = 0

        with open(rules_path, "r", encoding="utf-8") as rules_file:
            for line in rules_file:
                line = line.rstrip("\n")
                columns = line.split()

                if len(columns) != 6 or columns[3] != "->" or len(columns[2]) != 15 or len(columns[5]) != 15:
                    print("Unknown rule line '{}', ignoring.".format(line))
                else:
                    form, lemma, tag, _, rlemma, rtag = columns
                    if (form, lemma, tag) in self._rules:
                        print("Duplicate rule '{}', ignoring the second one.".format(line))
                    else:
                        self._rules[(form, lemma, tag)] = (rlemma, rtag)

    def process(self, form, lemma, tag):
        return self._rules.get((form, lemma, tag), None)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--rules", default=None, type=str, help="Rules to use")
    parser.add_argument("--rewrite", default=False, action="store_true", help="Update inplace")
    parser.add_argument("paths", nargs="+", type=str, help="Files to process")
    args = parser.parse_args()

    m = Rules(args.rules)

    changed, total = 0, 0
    for path in args.paths:
        form = None
        output = []
        with open(path, "r", encoding="utf-8") as path_file:
            analyses, recommended_index, selected_index = [], None, None

            for line in path_file:
                if line.startswith("<form>"):
                    form = xml.etree.ElementTree.fromstring(line).text

                if line.startswith("<tag "):
                    element = xml.etree.ElementTree.fromstring(line)
                    replaced = m.process(form, element.get("lemma"), element.text)

                    total += 1
                    if replaced is not None:
                        changed += 1
                        element.set("lemma", replaced[0])
                        element.text = replaced[1]
                    if total % 10000 == 0: print("Total {}, not found {}, changed {}".format(total, m.not_found, changed), file=sys.stderr)
                    output.append(xml.etree.ElementTree.tostring(element, encoding="unicode") + "\n")

                elif line.startswith(("<AM", "</tag")):
                    if line.startswith("<AM"):
                        if 'recommended="1"' in line: recommended_index = len(analyses)
                        if 'selected="1"' in line: selected_index = len(analyses)
                        analyses.append(line[:-len("</tag>\n" if line.endswith("</tag>\n") else "\n")])
                    if "</tag>" in line:
                        assert selected_index is not None or recommended_index is not None or len(analyses) == 1
                        chosen = selected_index if selected_index is not None else recommended_index if recommended_index is not None else 0
                        for index, analysis in enumerate(analyses):
                            if index == chosen:
                                element = xml.etree.ElementTree.fromstring(analysis)
                                replaced = m.process(form, element.get("lemma"), element.text)

                                total += 1
                                if replaced is not None:
                                    changed += 1
                                    element.set("lemma", replaced[0])
                                    element.text = replaced[1]
                                    analysis = xml.etree.ElementTree.tostring(element, encoding="unicode")
                                if total % 10000 == 0: print("Total {}, not found {}, changed {}".format(total, m.not_found, changed), file=sys.stderr)
                            output.append(analysis + ("</tag>\n" if index + 1 == len(analyses) and line.startswith("<AM") else "\n"))

                        analyses, recommended_index, selected_index = [], None, None
                        if line.startswith("</tag"):
                            output.append(line)
                else:
                    output.append(line)

        if args.rewrite:
            with open(path, "w", encoding="utf-8") as path_file:
                print("".join(output), end="", file=path_file)
    print("Total {}, not found {}, changed {}".format(total, m.not_found, changed), file=sys.stderr)
