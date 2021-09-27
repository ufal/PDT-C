#!/usr/bin/env python3
import argparse
import sys

import ufal.udpipe

INTERPUNCTION = {"(", ")", "[", "]", '"', ",", ";", "-", "/", "\\"}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("conllu_file", type=str, help="Input CoNLL-U file")
    args = parser.parse_args()

    conllu = ufal.udpipe.InputFormat.newConlluInputFormat()
    with open(args.conllu_file, "r", encoding="utf-8") as conllu_file:
        conllu.setText(conllu_file.read())

    sentence = ufal.udpipe.Sentence()
    error = ufal.udpipe.ProcessingError()
    output = ufal.udpipe.OutputFormat.newConlluOutputFormat()

    def has_interpunction(sentence, word):
        for w in sentence.words[1:]:
            if w.head == word.id and w.form in INTERPUNCTION:
                return True
        return False

    replacements = 0
    while conllu.nextSentence(sentence, error):
        for i in range(1, len(sentence.words)):
            word = sentence.words[i]
            if word.deprel.endswith("_IsParenthesisRoot"):
                if not has_interpunction(sentence, word):
                    parent, level = word, 0
                    while parent.head and \
                            sentence.words[parent.head].deprel.split("_")[0] in ("AuxC", "AuxP"):
                        parent = sentence.words[parent.head]
                        level += 1
                        if has_interpunction(sentence, parent):
                            break
                    if has_interpunction(sentence, parent):
                        word.deprel = word.deprel[:-len("_IsParenthesisRoot")]
                        if "_IsMember" in parent.deprel:
                            print("Word {}/{} has is_member".format(i, word.id),
                                  output.writeSentence(sentence), file=sys.stderr, sep="\n")
                            continue

                        if "_IsParenthesisRoot" in parent.deprel:
                            print("Word {}/{} has is_parenthesis_root".format(i, word.id),
                                  output.writeSentence(sentence), file=sys.stderr, sep="\n")
                        else:
                            parent.deprel = parent.deprel + "_IsParenthesisRoot"
                        replacements += 1
                        print(replacements, file=sys.stderr)
            elif "_IsParenthesisRoot" in word.deprel:
                raise ValueError("Unknown deprel '{}'".format(word.deprel))
        print(output.writeSentence(sentence), end="")
    if error.occurred():
        raise Exception(error.message)
