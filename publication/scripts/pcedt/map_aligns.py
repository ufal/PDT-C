import sys
import argparse
import re
import difflib
import numpy as np
from scipy.linalg import block_diag
from pprint import pprint

def read_tokens(token_str):
    return token_str.split(" ")

def read_aligns(align_str, shape):
    align_matrix = np.zeros(shape)
    aligns = align_str.split(" ")
    for align in aligns:
        xy = align.split("-")
        align_matrix[int(xy[0]), int(xy[1])] = 1
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


def extract_aligns(tokens1, tokens2):
    diff = list(difflib.context_diff(
        [x+"\n" for x in tokens1],
        [x+"\n" for x in tokens2],
        n=0))
    #print(diff)
    changes = extract_changes_from_diff(diff)
    if len(changes) > 0:
        #print(changes)
        return changes_to_align_matrix(changes, (len(tokens1), len(tokens2)))
    else:
        return np.eye(len(tokens1))
    #for span1, span2 in changes:
    #    print(" ".join([x[1] for x in new_s_tokens[span1[0]:span1[1]]]))
    #    print(" ".join([x[1] for x in old_s_tokens[span2[0]:span2[1]]]))

for i, line in enumerate(sys.stdin):
    #print(i)
    line = line.rstrip()
    new_en_tok_str, old_en_tok_str, encs_align_str, old_cs_tok_str, new_cs_tok_str = line.split("\t")
    
    new_en_tokens = read_tokens(new_en_tok_str)
    old_en_tokens = read_tokens(old_en_tok_str)
    en_aligns = extract_aligns(new_en_tokens, old_en_tokens)
    #print("EN_ALIGN")
    #print(en_aligns.shape)

    old_cs_tokens = read_tokens(old_cs_tok_str)
    new_cs_tokens = read_tokens(new_cs_tok_str)
    cs_aligns = extract_aligns(old_cs_tokens, new_cs_tokens)
    #print("CS_ALIGN")
    #print(old_cs_tokens)
    #print(new_cs_tokens)
    #print(cs_aligns.shape)

    encs_old_aligns = read_aligns(encs_align_str, (len(old_en_tokens), len(old_cs_tokens)))
    #print("ENCS_OLD_ALIGN")
    #print(encs_old_aligns.shape)

    encs_new_aligns = np.matmul(np.matmul(en_aligns, encs_old_aligns), cs_aligns)
    #print("ENCS_NEW_ALIGN")
    #print(encs_new_aligns.shape)
