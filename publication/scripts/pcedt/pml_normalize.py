import xml.etree.ElementTree as ET
from xml.sax.saxutils import unescape
import sys
import re
import argparse

parser = argparse.ArgumentParser(description="A script to adjust PML file")
parser.add_argument("--sort-id-elems", action='store_true', help="sort subelements of the element with an 'id' attribute alphabetically")
parser.add_argument("--remove-extra-lm", action='store_true', help="remove LM element if reduntant")
parser.add_argument("--remove-meta", action='store_true', help="remove 'meta' element under the root")
parser.add_argument("--remove-lang-sentence", action='store_true', help="remove '[eng,cze]_sentence' element")
parser.add_argument("--remove-root-nodetype", action='store_true', help="remove 'nodetype' element under '/tdata/trees/LM'")
parser.add_argument("--remove-p", action='store_true', help="remove phrase trees under 'p' elements")
parser.add_argument("--remove-annot-comment", action='store_true', help="remove 'annot_comment' elements")
parser.add_argument("--remove-empty-a", action='store_true', help="remove empty 'a' elements")
parser.add_argument("--remove-coref-src", action='store_true', help="remove 'src' element within the 'coref_text' tag")
parser.add_argument("--keep-zone", type=str, default=None, help="only the specified zone will be kept; format: LANGCODE")
parser.add_argument("--keep-tree", type=str, default=None, help="only the specified tree will be kept; format: [apt]")
args = parser.parse_args()

xmlstring = sys.stdin.read()
m = re.search(r'\sxmlns="([^"]+)"', xmlstring)
ns = { "pml" : m.group(1) }
#xmlstring = re.sub(r'\sxmlns="[^"]+"', '', xmlstring, count=1)
root = ET.fromstring(xmlstring)

######## sort subelements of elements with ID #########
if args.sort_id_elems:
    for id_elem in root.findall('.//*[@id]', ns):
        subelems = id_elem.getchildren()
        #print("BEFORE: " + str(lm.getchildren()))
        for subelem in subelems:
            id_elem.remove(subelem)
        subelems = sorted(subelems, key=lambda x: x.tag)
        for subelem in subelems:
            id_elem.append(subelem)
        #print("AFTER: " + str(lm.getchildren()))

########## delete redundant aux.rf/LM ###########

if args.remove_extra_lm:
    for ar in root.findall('.//pml:aux.rf', ns):
        lms = ar.findall('pml:LM', ns)
        if len(lms) == 1:
            ar.remove(lms[0])
            ar.text = lms[0].text
    for wr in root.findall('.//pml:w.rf', ns):
        lms = wr.findall('pml:LM', ns)
        if len(lms) == 1:
            wr.remove(lms[0])
            wr.text = lms[0].text
    for wr in root.findall('.//pml:w', ns):
        lms = wr.findall('pml:LM', ns)
        if len(lms) == 1:
            wr.remove(lms[0])
            for ch in lms[0].getchildren():
                wr.append(ch)

############### delete meta #####################

if args.remove_meta:
    for meta in root.findall('./pml:meta', ns):
        root.remove(meta)

############### delete [eng,cze]_sentence #####################

if args.remove_lang_sentence:
    for par in root.findall('.//*[pml:eng_sentence]', ns):
        for ch in par.findall('./pml:eng_sentence', ns):
            par.remove(ch)
    for par in root.findall('.//*[pml:cze_sentence]', ns):
        for ch in par.findall('./pml:cze_sentence', ns):
            par.remove(ch)

############### delete nodetype in roots #####################

if args.remove_root_nodetype:
    for par in root.findall('.//pml:trees/pml:LM', ns):
        for ch in par.findall('./pml:nodetype', ns):
            par.remove(ch)

############### delete phrase trees #####################

if args.remove_p:
    for par in root.findall('.//*[pml:p]', ns):
        for ch in par.findall('./pml:p', ns):
            par.remove(ch)
    for par in root.findall('.//*[pml:ptree.rf]', ns):
        for ch in par.findall('./pml:ptree.rf', ns):
            par.remove(ch)
    for par in root.findall('.//*[pml:references]', ns):
        for ch in par.findall('./pml:references', ns):
            for gch in ch.findall('./pml:reffile[@name="pdata"]', ns):
                ch.remove(gch)
            if not ch.getchildren():
                par.remove(c)

############### delete phrase trees #####################

if args.remove_annot_comment:
    for par in root.findall('.//*[pml:annot_comment]', ns):
        for ch in par.findall('./pml:annot_comment', ns):
            par.remove(ch)

############### delete empty a elements #################

if args.remove_empty_a:
    for par in root.findall('.//*[pml:a]', ns):
        for ch in par.findall('./pml:a', ns):
            if not ch.getchildren():
                par.remove(ch)

########## delete src elements within coref_text #########

if args.remove_coref_src:
    for par in root.findall('.//pml:coref_text//*[pml:src]', ns):
        for ch in par.findall('./pml:src', ns):
            par.remove(ch)

############### keep zone #####################

if args.keep_zone is not None:
    zones_elems = root.findall('.//pml:zones', ns)
    for zones_elem in zones_elems:
        zones = zones_elem.getchildren()
        for zone in zones:
            if zone.attrib["language"] != args.keep_zone:
                zones_elem.remove(zone)
    
############### keep tree #####################

if args.keep_tree is not None:
    trees_elems = root.findall('.//pml:trees', ns)
    for trees_elem in trees_elems:
        trees = trees_elem.getchildren()
        for tree in trees:
            if tree.tag != f"{{{ns['pml']}}}{args.keep_tree}_tree":
                trees_elem.remove(tree)

ET.register_namespace('', ns["pml"])
xmlstring = ET.tostring(root, encoding="unicode")
print(xmlstring)
