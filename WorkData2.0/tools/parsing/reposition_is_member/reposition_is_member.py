#!/usr/bin/env python3
import argparse
import sys

import ufal.udpipe

COORD_DEPRELS = ("Coord", "Apos")

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

    while conllu.nextSentence(sentence, error):
        for i in range(1, len(sentence.words)):
            word = sentence.words[i]
            if "_IsMember" in word.deprel:
                word.deprel = word.deprel.replace("_IsMember", "")
                while word.head and sentence.words[word.head].deprel.split("_")[0] not in COORD_DEPRELS:
                    if sentence.words[word.head].deprel.split("_")[0] not in ("AuxC", "AuxP"):
                        print("Word {} has {} before Coord/Apos".format(word.id, word.deprel),
                              output.writeSentence(sentence), file=sys.stderr, sep="\n")
                    word = sentence.words[word.head]
                assert sentence.words[word.head].deprel.split("_")[0] in COORD_DEPRELS
                if "_IsMember" not in word.deprel:
                    word.deprel = word.deprel + "_IsMember"
            elif "_IsMember" in word.deprel:
                raise ValueError("Unknown deprel '{}'".format(word.deprel))
        print(output.writeSentence(sentence), end="")
    if error.occurred():
        raise Exception(error.message)
