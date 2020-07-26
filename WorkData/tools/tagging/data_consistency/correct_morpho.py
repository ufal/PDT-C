#!/usr/bin/env python3
import collections
import fileinput
import hashlib
import io
import multiprocessing
import re
import sys

import correct_lemmas

def morpho_blocks():
    re_lemma_id = re.compile(r".[^_`\t]*")

    block_lemma_id, block = "", []
    for line in fileinput.input():
        lemma_id = line[:re_lemma_id.match(line).end()]
        if lemma_id == block_lemma_id:
            block.append(line)
        else:
            if block:
                yield "".join(block)
            block_lemma_id = lemma_id
            block = [line]
    yield "".join(block)

def process_block(block):
    real_stdout = sys.stdout
    sys.stdout = io.StringIO()

    analyses = []
    all_derivations = set()
    all_lemmas_without_derivations = set()
    for line in block.split("\n")[:-1]:
        lemma, tag, form = line.rstrip("\n").split("\t")

        raw_lemma, sense, reference, style, terms, derivations, comments = correct_lemmas.parse_lemma_and_validate(form, lemma, tag, label="")

        if tag.startswith("X"):
            print("M-X Tag starts with X for lemma {} and tag {}".format(lemma, tag))

        analyses.append((tag, form))
        all_derivations |= set(derivations)
        all_lemmas_without_derivations.add(re.sub(r"_\^?\(\*[^)]*\)", "", lemma))

    lemma_id = raw_lemma + ("-{}".format(sense) if sense is not None else "")

    if len(all_lemmas_without_derivations) > 1:
        print("M-SameLemma The lemma {} has multiple variants: {}".format(lemma_id, all_lemmas_without_derivations))

    tag_set = set(tag for tag, _ in analyses)
    pos1 = set(tag[:1] for tag in tag_set)
    if len(pos1) > 1:
        print("M-POS Multiple POS tags {} for lemma {}".format(pos1, lemma))
    if any(pos == "V" for pos in pos1):
        aspect = set(tag[12:13] for tag in tag_set)
        if len(aspect) > 1:
            print("M-Aspect Multiple aspects {} for lemma {}".format(aspect, lemma))

    pos3 = set(tag[:3] for tag in tag_set)
    if any(pos.startswith("NN") for pos in pos3):
        if len(pos3) > 1:
            print("M-Gender Multiple POS tags {} for lemma {}".format(pos3, lemma))

        negatives = set(tag[10:11] for tag in tag_set)
        if "N" in negatives and not "A" in negatives:
            print("M-Negative Lemma {} has negative tags without any positive one".format(lemma))

    for tag, _ in analyses:
        if tag not in tag_set:
            print("M-Gold Lemma {} has multiple analyses with the same tag {}: {}".format(lemma, tag, [f for t, f in analyses if t == tag]))
        else:
            tag_set.remove(tag)

    if all(tag.startswith("BN") for tag, _ in analyses):
        paradigm = None
    else:
        paradigm = hashlib.sha1()
        paradigm.update("\t".join("{} {}".format(tag, form) for tag, form in sorted(analyses)).encode("utf-8"))
        paradigm = paradigm.digest()

    log = sys.stdout.getvalue()
    sys.stdout = real_stdout

    return lemma_id, all_derivations, paradigm, log

#     generics = []
#     for tag in tag_set:
#         if tag[-1] != "-" and tag[:-1] + "-" not in tag_set:
#             generics.append(tag)
#     if generics:
#         print("M-GenVar Lemma {} has tags without a generic variant: {}".format(lemma, generics))


if __name__ == "__main__":
    pool = multiprocessing.Pool(8)

    lemma_sense_re = re.compile(r"-[0-9]+$")

    lemmas = {}
    raw_lemmas = collections.defaultdict(lambda: set())
    paradigms = collections.defaultdict(lambda: [])
    for lemma_id, derivations, paradigm, log in pool.imap_unordered(process_block, morpho_blocks(), chunksize=1000):
        print(log, end="")

        assert lemma_id not in lemmas
        lemmas[lemma_id] = derivations
        raw_lemmas[lemma_sense_re.sub("", lemma_id)].add(lemma_id)
        if paradigm is not None: paradigms[paradigm].append(lemma_id)

    for lemma_id, derivations in lemmas.items():
        for link_type, link in derivations:
            if link_type not in ["DD", "DS", "GC"]:
                continue
            if link == lemma_id:
                print("M-ExiDer Lemma {} has derivational link of type {} to itself".format(lemma_id, link_type))
            if link not in lemmas:
                wrong_sense_links = raw_lemmas.get(lemma_sense_re.sub("", link), None)
                if wrong_sense_links is not None:
                    print("M-ExiDer-Sense Lemma {} has derivational link of type {} to lemma {} with wrong sense ({} exist)".format(lemma_id, link_type, link, wrong_sense_links))
                else:
                    print("M-ExiDer Lemma {} has derivational link of type {} to non-existing lemma {}".format(lemma_id, link_type, link))

    for lemma_ids in paradigms.values():
        if len(lemma_ids) > 1:
            print("M-Paradigm The following lemmas has the same set of (tag, form) pairs: {}".format(lemma_ids))
