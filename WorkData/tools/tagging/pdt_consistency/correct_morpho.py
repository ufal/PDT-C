#!/usr/bin/env python3
import fileinput
import multiprocessing
import re
import sys

import correct_lemmas

def morpho_blocks():
    re_lemma_id = re.compile(r".(?:[^-_]|-[^0-9])*")

    block_lemma_id, block = "", []
    for line in fileinput.input():
        lemma_id = line[:re_lemma_id.match(line).end()]
        if lemma_id == block_lemma_id:
            block.append(line)
        else:
            yield "".join(block)
            block_lemma_id = lemma_id
            block = [line]
    yield "".join(block)

def process_block(block):
    for line in block.split("\n")[:-1]:
        lemma, tag, form = line.rstrip("\n").split("\t")
        correct_lemmas.parse_lemma_and_validate(form, lemma, tag)

if __name__ == "__main__":
    pool = multiprocessing.Pool(6)

    for _ in pool.imap_unordered(process_block, morpho_blocks(), chunksize=1000):
        pass
