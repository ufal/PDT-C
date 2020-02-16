#!/usr/bin/env python3
import argparse
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

    def process(self, form, lemma, tag):
        if lemma is None or tag is None:
            return None

        analyses = self._analyses(form)

        # Only for analyses not present in the dictionary
        if (lemma, tag) not in analyses:
            self.not_found += 1

            # Try finding a version without _:T _:W and with different 13. tag
            lemma_no_perf = lemma.replace("_:T", "").replace("_:W", "")
            match, matches = None, 0
            for (l, t) in analyses:
                if l != lemma_no_perf: continue

                if t[:12] == tag[:12] and t[13:] == tag[13:]:
                    match = l, t
                    matches += 1
                elif t.startswith(("Vp", "Vs")) and t[:7] == tag[:7] and t[7] == "-" and tag[7] == "X" and  t[8:12] == tag[8:12] and t[13:] == tag[13:]:
                    match = l, t
                    matches += 1
                elif t.startswith(("Vp", "Vs")) and t[:7] == tag[:7] and t[7] == "-" and tag[7] == "2" and  t[8:12] == tag[8:12] and t[13] == "s" and tag[13] == "-" and t[14:] == tag[14:]:
                    match = l, t
                    matches += 1

            if matches == 1:
                return match


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
            for line in path_file:
                if line.startswith("<form>"):
                    form = xml.etree.ElementTree.fromstring(line).text

                if line.startswith(("<AM", "<tag ")):
                    suffix = "</tag>\n" if line.startswith("<AM") and line.endswith("</tag>\n") else "\n"
                    element = xml.etree.ElementTree.fromstring(line[:-len(suffix)])
                    replaced = m.process(form, element.get("lemma"), element.text)

                    total += 1
                    if replaced is not None:
                        changed += 1
                        element.set("lemma", replaced[0])
                        element.text = replaced[1]
                    output.append(xml.etree.ElementTree.tostring(element, encoding="unicode") + suffix)

                    if total % 100000 == 0:
                        print("Total {}, not found {}, changed {}".format(total, m.not_found, changed))
                else:
                    output.append(line)
        if args.rewrite:
            with open(path, "w", encoding="utf-8") as path_file:
                print("".join(output), end="", file=path_file)
    print("Total {}, not found {}, changed {}".format(total, m.not_found, changed))
