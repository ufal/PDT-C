#!/usr/bin/env python3
import argparse
import re
import xml.etree.ElementTree


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--rewrite", default=False, action="store_true", help="Update inplace")
    parser.add_argument("paths", nargs="+", type=str, help="Files to process")
    args = parser.parse_args()

    changed, total = 0, 0
    for path in args.paths:
        form = None
        output = []
        with open(path, "r", encoding="utf-8") as path_file:
            for line in path_file:
                if line.startswith("<form>"):
                    form = xml.etree.ElementTree.fromstring(line).text

                if line.startswith(("<AM", "<tag ")):
                    suffix = "</tag>\n" if line.startswith("<AM") and line.endswith("</tag>\n") else "\n"
                    element = xml.etree.ElementTree.fromstring(line[:-len(suffix)])

                    total += 1
                    lemma = element.get("lemma")
                    if re.match(r"^(\w|ch)$", form, re.I | re.U) and re.match(r"^(\w|ch)-3+_\^\(označení_pomocí_písmene\)$", lemma, re.I | re.U):
                        new_lemma = form + "-33_^(označení_pomocí_písmene)"
                        if new_lemma != lemma or element.text != "NNNXX-----A----":
                            changed += 1
                        element.set("lemma", new_lemma)
                        element.text = "NNNXX-----A----"
                    output.append(xml.etree.ElementTree.tostring(element, encoding="unicode") + suffix)

                    if total % 100000 == 0:
                        print("Total {}, changed {}".format(total, changed))
                else:
                    output.append(line)
        if args.rewrite:
            with open(path, "w", encoding="utf-8") as path_file:
                print("".join(output), end="", file=path_file)
    print("Total {}, changed {}".format(total, changed))
