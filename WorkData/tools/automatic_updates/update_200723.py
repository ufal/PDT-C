#!/usr/bin/env python3
import argparse
import re
import sys
import xml.etree.ElementTree

import ufal.morphodita

class Morphology:
    def __init__(self, model_path):
        self._model = ufal.morphodita.Morpho.load(model_path)
        self.not_found = 0

    def _analyses(self, form):
        lemmas = ufal.morphodita.TaggedLemmas()
        if self._model.analyze(form, self._model.NO_GUESSER, lemmas) < 0:
            return []
        return [(lemma.lemma, lemma.tag) for lemma in lemmas]

    def _raw(self, lemma):
        return self._model.rawLemma(lemma)

    def _lid(self, lemma):
        return self._model.lemmaId(lemma)

    def process(self, form, lemma, tag):
        if lemma is None or tag is None or len(tag) != 15:
            return None
        raw_lemma, ori_lemma, ori_tag = self._raw(lemma), lemma, tag

        analyses = self._analyses(form)

        # Only for analyses not present in the dictionary
        if (lemma, tag) not in analyses:
            self.not_found += 1

            # Remove _:B, replace -8 to -b
            if "_:B" in lemma:
                lemma = lemma.replace("_:B", "")
                if tag[14] == "8":
                    tag = tag[:14] + "b"
                else:
                    tag = "B" + tag[1:]

            # Remove _:W
            if "_:W" in lemma and "_:T" not in lemma and tag[12] == "-":
                lemma = lemma.replace("_:W", "")
                tag = tag[:12] + "P" + tag[13:]

            # Remove _:T
            if "_:T" in lemma and "_:W" not in lemma and tag[12] == "-":
                lemma = lemma.replace("_:T", "")
                tag = tag[:12] + "I" + tag[13:]
            lemma = lemma.replace("_:W", "").replace("_:T", "")

            # Remove _,t _,x
            lemma = lemma.replace("_,t", "")
            lemma = lemma.replace("_,x", "")

            # Remove manual typed derivations
            lemma = re.sub( r"_\^\(\^(?!(?:D[DS])|(?:G[C2])|(?:[AO]R))[A-Z][A-Z]\*[^)]*\)_\(", "_^(", lemma)
            lemma = re.sub(r"_\^?\(\^(?!(?:D[DS])|(?:G[C2])|(?:[AO]R))[A-Z][A-Z]\*[^)]*\)", "", lemma)

            # Fix 8th position for V[ps]
            if tag.startswith(("Vp", "Vs")) and tag[7] == "X":
                tag = tag[:7] + "-" + tag[8:]

            # Replace A2 to S2
            if tag == "A2--------A----":
                tag = "S2--------A----"

            # Casing for -77 lemmas
            if "-77" in lemma and len(raw_lemma) > 1 and raw_lemma.isupper():
                lemma = raw_lemma[0].upper() + raw_lemma[1:].lower() + lemma[len(raw_lemma):]

            # Copy position 13 if unique
            if tag[12] == "-":
                all_but_13 = set(t for _, t in analyses if t[:12] == tag[:12] and t[13:] == tag[13:])
                if len(all_but_13) == 1 and list(all_but_13)[0][12] != "-":
                    tag = list(all_but_13)[0]

            # Numerals
            if sum(1 for l, t in analyses if t == tag) == 0 and tag[0] == "C":
                matches = [(l, t) for l, t in analyses if t[:1] == tag[:1] and t[2:14] == tag[2:14]]
                if len(matches) == 1:
                    return matches[0]

                if tag[2] == "X":
                    matches = [(l, t) for l, t in analyses if t[:1] == tag[:1] and t[2] == "-" and t[3:14] == tag[3:14]]
                    if len(matches) == 1:
                        return matches[0]

                if tag.startswith("Cy"):
                    matches = [(l, t) for l, t in analyses if t[:2] == "NN" and t[2:10] == tag[2:10] and t[11:] == tag[11:]]
                    if len(matches) == 1:
                        return matches[0]

                if tag == "ClXXX----------" and lemma == "pár-1":
                    tag = "Ca--X----------"

            if raw_lemma in ["nula", "tisíc", "sto", "milion", "milión", "miliarda",
                             "bilion", "bilión", "biliarda", "trilion", "trilión", "triliarda"] and tag.startswith("NN"):
                matches = [(l, t) for l, t in analyses if t[:2] == "Cz" and t[2:10] == tag[2:10] and t[11:] == tag[11:]]
                if len(matches) == 1:
                    return matches[0]

            if form.lower() == "tisíc" and lemma == "tisíc-1`1000" and tag in [
                    "ClXS2----------", "ClXS3----------", "ClXS6----------", "ClXS7----------", "ClNP2----------"]:
                lemma, tag = "tisíc`1000", "CzIXX----------"
            if form.lower() == "tis" and lemma == "tisíc-2`1000" and tag == "NNIXX-----A---b":
                lemma, tag = "tisíc`1000", "CzIXX---------b"
            if form.lower() == "mil" and lemma == "milión`1000000" and tag == "NNIXX-----A---b":
                lemma, tag = "milión`1000000", "CzIXX---------b"
            if form.lower() == "mld" and lemma == "miliarda`1000000000" and tag == "NNFXX-----A---b":
                lemma, tag = "miliarda`1000000000", "CzFXX---------b"

            # Pronouns
            if sum(1 for l, t in analyses if t == tag) == 0 and tag[0] == "P":
                matches = [(l, t) for l, t in analyses if t[:1] == tag[:1] and t[2:14] == tag[2:14]]
                if len(matches) == 1:
                    return matches[0]

                if tag[2] == "M":
                    matches = [(l, t) for l, t in analyses if t[:1] == tag[:1] and t[2] == "-" and t[3:14] == tag[3:14]]
                    if len(matches) == 1:
                        return matches[0]

                if tag.startswith(("P6", "P7")):
                    tag = tag[:3] + "-" + tag[4:]

            if ori_lemma != lemma or ori_tag != tag:
                return lemma, tag


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="czech-morfflex-pdt-c/czech-morfflex-pdt-c.dict",
                        type=str, help="MorphoDiTa model to load")
    parser.add_argument("--rewrite", default=False, action="store_true", help="Update inplace")
    parser.add_argument("paths", nargs="+", type=str, help="Files to process")
    args = parser.parse_args()

    m = Morphology(args.model)

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
                        print("{} {} -> {} {}".format(element.get("lemma"), element.text, replaced[0], replaced[1]))
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
                                    print("{} {} -> {} {}".format(element.get("lemma"), element.text, replaced[0], replaced[1]))
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
