import sys
import argparse
import re
import difflib
import numpy as np
from scipy.linalg import block_diag
from pprint import pprint

# Alignment types and sources are encoded as integers in matrices.
# Alignment type codes are specified in ALIGN_TYPE2CODE.
# The minimum 1e2 difference between each two codes guarantees that a word can have at most 100 counterparts
# of one type to be correctly reconstructed after decoding.
# Alignment source coeficients in ALIGN_SRC_COEF follow the step of 1e2*max(ALIGN_TYPE2CODE), which currently
# equals to 1e6. It ensures the sources can be identified in a code that was created as a linear combination 
# of coeficients in ALIGN_SRC_COEF.

ALIGN_TYPE2CODE = {
    "" : 1,
    "int" : 1e2,
    "gdfa": 1e4,
}
ALIGN_SRC_COEF = {
    "g" : 1,
    "f" : 1e6,
}

def encode_aligntype(aligntype):
    return ALIGN_TYPE2CODE[aligntype]

# code is int
# coeftable is str -> int dictionary, mapping names to coefs
def decode_with_coeftable(code, coeftable):
    ct_items = sorted(coeftable.items(), key=lambda x: x[1], reverse=True)
    codes = []
    is_present = []
    resid = code
    residcodes4names = {}
    for name, coef in ct_items:
        if resid >= coef:
            residcodes4names[name] = int(resid / coef)
        resid = resid % coef
    return residcodes4names
    
def decode_aligntype(code):
    align_types = []
    codes4src = decode_with_coeftable(code, ALIGN_SRC_COEF)
    for alisrc, typecode in codes4src.items():
        align_types_dict = decode_with_coeftable(typecode, ALIGN_TYPE2CODE)
        align_types_name = ".".join(sorted(align_types_dict.keys(), reverse=True))
        align_types.append(align_types_name + "-" + alisrc)
    return ",".join(align_types)

def read_tokens(token_str):
    return token_str.split(" ")

def read_aligns(align_str, shape):
    align_matrix = np.zeros(shape)
    #print(shape, file=sys.stderr)
    aligns = align_str.split(" ")
    for align in aligns:
        align_info = align.split(":")
        #print(align_info, file=sys.stderr)
        x, y = align_info[0].split("-")
        for ai in (align_info[1] if len(align_info) > 1 else "").split("."):
            code = encode_aligntype(ai)
            align_matrix[int(x), int(y)] += code
    return align_matrix

#def read_token_file(path):
#    data = []
#    with open(path, 'rt') as f:
#        curr_sent_id = None
#        sent_data = []
#        for line in f:
#            line = line.rstrip()
#            token_id, token = line.split("\t")
#            token_id = re.sub(r'^.*/', '', token_id)
#            token_id = re.sub(r'wsj_', 'wsj', token_id)
#            sent_id = re.sub(r'\.[^.]*$', '', token_id)
#            if curr_sent_id is not None and curr_sent_id != sent_id:
#                data.append(sent_data)
#                sent_data = []
#            sent_data.append((token_id, token))
#            curr_sent_id = sent_id
#    return data

        

def extract_changes_from_diff(diff):
    changes = []
    diff1_types, diff2_types = ([], [])
    span1, span2 = (None, None)
    for line in diff:
        if re.match(r'\*{15}', line) and span1 is not None and span2 is not None:
            if len(diff1_types) == 0:
                span1 = (span1[0]+1, span1[1])
            if len(diff2_types) == 0:
                span2 = (span2[0]+1, span2[1])
            changes.append((span1, span2))
            diff1_types, diff2_types = ([], [])
            span1, span2 = (None, None)
            continue
        m = re.search(r'(?<=\*\*\* )(\d+),?(\d*)', line)
        if m:
            span1 = (int(m.group(1))-1, int(m.group(2)) if len(m.group(2)) > 0 else int(m.group(1)))
            continue
        m = re.search(r'(?<=--- )(\d+),?(\d*)', line)
        if m:
            span2 = (int(m.group(1))-1, int(m.group(2)) if len(m.group(2)) > 0 else int(m.group(1)))
            continue
        if span1 is not None and span2 is None:
            diff1_types.append(line[0])
        elif span1 is not None and span2 is not None:
            diff2_types.append(line[0])
    if span1 is not None and span2 is not None:
        if len(diff1_types) == 0:
            span1 = (span1[0]+1, span1[1])
        if len(diff2_types) == 0:
            span2 = (span2[0]+1, span2[1])
        changes.append((span1, span2))
    return changes



def changes_to_align_matrix(changes, shape):
    changes_transp = [(np.array([span1[0], span2[0]]), np.array([span1[1], span2[1]])) for span1, span2 in changes]
    res = np.empty((0,0))
    for start, end in changes_transp:
        a = np.eye(min(start-np.array(res.shape)))
        b = np.ones(end-start)
        res = block_diag(res, a, b)
    res = block_diag(res, np.eye(min(np.array(shape)-np.array(res.shape))))
    return res

def spans_to_mask(spans, length):
    mask = np.ones((length, 1))
    for s,e in spans:
        mask[s:e] = 0
    return mask


def extract_aligns(tokens1, tokens2):
    diff = list(difflib.context_diff(
        [x+"\n" for x in tokens1],
        [x+"\n" for x in tokens2],
        n=0))
    # print(diff)
    changes = extract_changes_from_diff(diff)
    if len(changes) > 0:
        # print(changes)
        align_matrix = changes_to_align_matrix(changes, (len(tokens1), len(tokens2)))
    else:
        align_matrix = np.eye(len(tokens1))
    mask = spans_to_mask([span1 for span1, span2 in changes], len(tokens1))
    return align_matrix, mask
    #for span1, span2 in changes:
    #    print(" ".join([x[1] for x in new_s_tokens[span1[0]:span1[1]]]))
    #    print(" ".join([x[1] for x in old_s_tokens[span2[0]:span2[1]]]))

def print_aligns(align_matrix, align_mask=None):
    align_list = []
    for i in range(align_matrix.shape[0]):
        for j in range(align_matrix.shape[1]):
            if align_matrix[i, j] > 0 and (align_mask is None or align_mask[i, j] > 0):
                align_type = decode_aligntype(align_matrix[i, j])
                align_list.append("{:d}-{:d}:{:s}".format(i, j, align_type))
    print(" ".join(align_list))


for i, line in enumerate(sys.stdin):
    #print(i, file=sys.stderr)
    line = line.rstrip()
    line_items = line.split("\t")
    new_en_tok_str, old_en_tok_str, encs_align_str, old_cs_tok_str, new_cs_tok_str, encs_aux_new_align_str = [line_items[i] if i < len(line_items) else None for i in range(6)]
    
    #print("EN_ALIGN")
    new_en_tokens = read_tokens(new_en_tok_str)
    old_en_tokens = read_tokens(old_en_tok_str)
    en_aligns, en_mask = extract_aligns(new_en_tokens, old_en_tokens)
    #print(en_aligns.shape)

    #print("CS_ALIGN")
    old_cs_tokens = read_tokens(old_cs_tok_str)
    new_cs_tokens = read_tokens(new_cs_tok_str)
    cs_aligns, cs_mask = extract_aligns(new_cs_tokens, old_cs_tokens)
    cs_aligns = np.transpose(cs_aligns)
    cs_mask = np.transpose(cs_mask)
    #print(old_cs_tokens)
    #print(new_cs_tokens)
    #print(cs_aligns.shape)

    encs_aux_new_aligns = None
    if encs_aux_new_align_str is not None:
        encs_aux_new_aligns = read_aligns(encs_aux_new_align_str, (len(new_en_tokens), len(new_cs_tokens)))

    encs_old_aligns = read_aligns(encs_align_str, (len(old_en_tokens), len(old_cs_tokens)))
    #print("ENCS_OLD_ALIGN")
    #print(encs_old_aligns.shape)

    encs_new_aligns = np.matmul(np.matmul(en_aligns, encs_old_aligns), cs_aligns)
    #print("ENCS_NEW_ALIGN")
    #print(encs_new_aligns.shape)

    encs_mask = np.matmul(en_mask, cs_mask)
    encs_compl_mask = np.ones(encs_mask.shape) - encs_mask
    if encs_aux_new_aligns is not None:
        encs_new_aligns = ALIGN_SRC_COEF["g"]*encs_mask*encs_new_aligns + ALIGN_SRC_COEF["f"]*encs_compl_mask*encs_aux_new_aligns

    print_aligns(encs_new_aligns)
