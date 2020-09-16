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

        # Rewrite PJ* to P4*
        if tag.startswith("PJ"):
            tag = "P4" + tag[2:]

        # Rewrite multiletter lemmas with sense 33 and _^(označení_pomocí_písmen(|e))
        # to sense 88, remove addinfo and use tag BNXXX-----A----
        if len(raw_lemma) > 1 and (lemma == "{}-33_^(označení_pomocí_písmen)".format(raw_lemma) or
                                   lemma == "{}-33_^(označení_pomocí_písmene)".format(raw_lemma)):
            lemma = "{}-88".format(raw_lemma)
            tag = "BNXXX-----A----"

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
