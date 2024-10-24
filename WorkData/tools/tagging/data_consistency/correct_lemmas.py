#!/usr/bin/env python3
import fileinput
import re

def parse_lemma(lemma, label):
    # Parse lemma
    raw_lemma, sense, reference, style, terms, derivations, comments = lemma, None, None, None, [], [], []

    # Lemma ends by one of -[0-9] _ ` on non-first position
    match = re.search(r"(?<=.)(-[0-9]|_|`)", lemma)
    if match is not None:
        raw_lemma = lemma_id = lemma[:match.start()]
        info = lemma[match.start():]
        match = re.search(r"^-[0-9]+", info)
        if match is not None:
            sense = int(info[1:match.end()])
            lemma_id = "{}-{}".format(raw_lemma, sense)
            assert lemma.startswith(lemma_id)

            if not (sense >= 1 and sense < 255):
                print(label, "LS-Rng Bad range of lemma sense of lemma {}".format(lemma))

            info = info[match.end():]

        # Parse the comments into
        # - reference
        if info.startswith("`"):
            info = info[1:]
            match = re.search(r"(?<=.)(-[0-9]|_)", info)
            reference_end = len(info) if match is None else match.start()
            reference = info[1:reference_end]
            info = info[reference_end:]

        # - obsolete categories
        while info.startswith(("_:B", "_:T", "_:W")):
            print(label, "C-No Obsolete category {} in lemma {}".format(info[2], lemma))
            info = info[3:]

        # - terms
        while info.startswith("_;"):
            terms.append(info[2])
            info = info[3:]

        # - style
        while info.startswith("_,"):
            if style is not None:
                print(label, "S-1 Multiple styles in lemma {}".format(lemma))
            style = info[2]
            info = info[3:]

        # - derivations and comments
        if info.startswith("_^"):
            info = info[2:]
            while info.startswith("("):
                rparent = info.find(")")
                if rparent < 0: rparent = len(info)
                comments.append(info[1:rparent])
                info = info[rparent + 1:]
                if info.startswith("_^("):
                    print(label, "C-Mul Other than first lemma comment starts with ^ for lemma {}".format(lemma))
                    info = info[2:]
                elif info.startswith("_("):
                    info = info[1:]

                derivation_type = ""
                if comments[-1].startswith("^"):
                    star = comments[-1].find("*")
                    if star >= 0:
                        derivation_type = comments[-1][1:star]
                        comments[-1] = comments[-1][star:]
                if comments[-1].startswith("**"):
                    if len(comments[-1]) == 2:
                        print(label, "D-Fmt Expected non-empty derivation after ** in lemma {}".format(lemma))
                    derivations.append((derivation_type, comments.pop()[2:]))
                elif comments[-1].startswith("*"):
                    derivation = comments.pop()[1:]
                    match = re.search(r"^[0-9]+", derivation)
                    if match is not None:
                        strip = int(derivation[:match.end()])
                        derivation = derivation[match.end():]
                    else:
                        strip = 0
                        print(label, "D-Fmt Expected at least one digit after * in lemma {}".format(lemma))
                    if strip > len(lemma_id):
                        print(label, "D-Fmt Derivation link tries to remove more characters than available for lemma {}".format(lemma))
                    strip = max(0, len(lemma_id) - strip)
                    derivations.append((derivation_type, lemma_id[:strip] + derivation))

        if info:
            print(label, "Cannot parse lemma info of lemma {}".format(lemma))

    return raw_lemma, sense, reference, style, terms, derivations, comments

def parse_lemma_and_validate(form, lemma, tag, label):
    # Parse lemma
    raw_lemma, sense, reference, style, terms, derivations, comments = parse_lemma(lemma, label)

    # Special lemmas
    form_equal_lemma = len(raw_lemma) == len(form) and all(l == f if l.isupper() else l.lower() == f.lower() for l, f in zip(raw_lemma, form))
    form_equal_lemma_initial_case = form_equal_lemma and form[0] == raw_lemma[0]
    if sense == 77 and (
            tag != "F%-------------" or not form_equal_lemma_initial_case or reference or style or terms or derivations or comments):
        print(label, "SL-77 Sense 77 implies tag F%, lemma==form and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))
    if tag == "F%-------------" and (
            sense != 77 or not form_equal_lemma_initial_case or reference or style or terms or derivations or comments):
        print(label, "SL-F% Tag F% implies sense 77, lemma==form and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))
    if sense == 88 and (
            tag != "BNXXX-----A----" or not form_equal_lemma or reference or style or terms or derivations or comments):
        print(label, "SL-88 Sense 88 implies tag BNXXX, lemma==form and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))
    if sense == 33 and (
            tag != "Q3-------------" or not form_equal_lemma_initial_case or (len(raw_lemma) != 1 and raw_lemma.lower() != "ch") or reference or style or terms or derivations or comments):
        print(label, "SL-33 Sense 33 implies tag Q3, lemma is single letter, lemma==form and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))
    if tag == "Q3-------------" and (
            sense != 33 or not form_equal_lemma_initial_case or (len(raw_lemma) != 1 and raw_lemma.lower() != "ch") or reference or style or terms or derivations or comments):
        print(label, "SL-Q3 Tag Q3 implies sense 33, lemma is single letter, lemma==form and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))
    if sense == 99 and (
            tag != "BNXXX-----A----" or not form_equal_lemma or style or terms != ["Y"] or derivations or comments):
        print(label, "SL-99 Sense 99 implies tag BNXXX, lemma==form, term Y and no other lemma info for lemma {} tag {} form {}".format(lemma, tag, form))

    # Typed derivation links
    for link_type, link in derivations:
        if link_type not in ["", "DD", "DS", "GC"]:
            print(label, "D-Type Unknown derivation link type {} for lemma {}".format(link_type, lemma))
#         if link_type == "GC" and style not in ["h", "n", "l", "e", "v"]:
#             print(label, "D-GC For derivation link GC, style is expected to be one of `hnlev` for lemma {}".format(lemma))
#         if link_type == "DD" and style not in ["a", "s"]:
#             print(label, "D-DD For derivation link GC, style is expected to be one of `as` for lemma {}".format(lemma))
#         if link_type == "DS" and style not in ["i"]:
#             print(label, "D-DS For derivation link GC, style is expected to be `i` for lemma {}".format(lemma))

    # Style valid
    if style is not None and style not in ["a", "e", "h", "i", "l", "n", "s", "v"]:
        print(label, "S-Unk Unknown style in lemma {}".format(lemma))

    # Terms valid
    for term in terms:
        if term not in ["E", "G", "m", "U", "Y", "o"]:
            print(label, "T-Unk Unknown term in lemma {}".format(lemma))
            break
    else:
        if len(set(terms)) < len(terms):
            print(label, "T-Rpt Repeated term in lemma {}".format(lemma))
        if "".join(terms) != "".join(sorted(terms, key=lambda l: "z" if l == "m" else l.lower())):
            print(label, "T-Ord Terms not sorted (case insensitively) in lemma {}".format(lemma))

#     # Uppercase lemmas as a term
#     if raw_lemma[0].isupper() and not terms:
#         print(label, "T-Uc Uppercase lemma without term {}".format(lemma))

    # Specific terms are nouns
    if (set(terms) & {"E", "G", "m", "Y"}) and not tag.startswith(("NN", "AU", "BN", "SN")):
        print(label, "T-NN Term EGmY should imply NN/AU/BN/SN, but got lemma {} and tag {}".format(lemma, tag))

    # Tags
    if len(tag) != 15:
        print(label, "T-15 Tags should always consist of 15 characters for lemma {} and tag {}".format(lemma, tag))

    if len(tag) >= 5 and tag[3:5] in ["SX", "PX"]:
        if (raw_lemma, tag) not in [("její", "PSFSXFS3-------"), ("jejíž", "P1FSXFS3-------"), ("jejíž", "P1FSXFS3------2")]:
            print(label, "T-SPX Tag cannot have number without case (SX/PX) in lemma {} and tag {}".format(lemma, tag))

    # Aspects
    if len(tag) > 12 and tag.startswith("V") != (tag[12] in ["P", "I", "B"]):
        print(label, "T-A Tag starts with V iff tag position 13 is [PIB] in lemma {} and tag {}".format(lemma, tag))


    return raw_lemma, sense, reference, style, terms, derivations, comments


if __name__ == "__main__":
    for line in fileinput.input():
        line = line.rstrip("\n")
        if not line:
            continue

        form, lemma, tag, *rest = line.split("\t")
        parse_lemma_and_validate(form, lemma, tag, rest[0] if rest else "")
