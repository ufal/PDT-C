#!/usr/bin/env python3
import argparse
import re
import sys
import xml.etree.ElementTree

# Single letters
letters = {
    "A", "Á", "B", "C", "Č", "D", "Ď", "E", "É", "Ě", "F", "G", "H", "Ch", "I", "Í", "J", "K", "L", "M", "N",
    "Ň", "O", "Ó", "P", "Q", "R", "Ř", "S", "Š", "T", "Ť", "U", "Ú", "Ů", "V", "W", "X", "Y", "Ý", "Z", "Ž",
}
letters.update([letter.lower() for letter in letters])

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
                    lemma, tag = element.get("lemma"), element.text

                    if tag and lemma and form:
                        # Term comments
                        def normalize_terms(match):
                            terms = set()
                            for term in match.group(0)[2:].split("_;"):
                                if term in "EGo":
                                    terms.add(term)
                                elif term in "SY":
                                    terms.add("Y")
                                elif term in "UHL":
                                    terms.add("U")
                                elif term in "KRm":
                                    terms.add("m")
                            return "".join("_;{}".format(term) for term in sorted(terms, key=lambda t: "z" if t == "m" else t.lower())) if terms else ""
                        new_lemma = re.sub("(:?_;[a-zA-Z0-9])+", normalize_terms, lemma)
                        if new_lemma != lemma:
                            changed += 1
                            lemma = new_lemma
                            print("TermNorm {}-{} -> {}-{}".format(element.get("lemma"), tag, lemma, tag))
                            element.set("lemma", lemma)

                        # Single letters
                        if form in letters and (
                                (lemma.startswith("{}-33".format(form)) and tag == "NNNXX-----A----") or
                                (lemma.startswith("{}-88".format(form)) and tag == "BNXXX-----A----")):
                            changed += 1
                            lemma = "{}-33".format(form)
                            tag = "Q3-------------"
                            print("SL-33 {}-{} -> {}-{}".format(element.get("lemma"), element.text, lemma, tag))
                            element.set("lemma", lemma)
                            element.text = tag

                        # T-SPX consistency
                        if len(tag) >= 5 and tag[3:5] in ["SX", "PX"]:
                            if not (lemma.startswith("její") and tag in ["PSFSXFS3-------", "P1FSXFS3------2"]):
                                changed += 1
                                tag = tag[:3] + "XX" + tag[5:]
                                print("T-SPX {}-{} -> {}-{}".format(lemma, element.text, lemma, tag))
                                element.text = tag
                    output.append(xml.etree.ElementTree.tostring(element, encoding="unicode") + suffix)

                    if total % 100000 == 0:
                        print("Total {}, changed {}".format(total, changed), file=sys.stderr)
                else:
                    output.append(line)
        if args.rewrite:
            with open(path, "w", encoding="utf-8") as path_file:
                print("".join(output), end="", file=path_file)
    print("Total {}, changed {}".format(total, changed), file=sys.stderr)
