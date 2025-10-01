import xml.etree.ElementTree as ET
from xml.sax.saxutils import unescape
import sys
import re
import argparse

parser = argparse.ArgumentParser(description="A script to adjust PML file")
parser.add_argument("--style", choices=['pdt_a', 'pdt_t', 'pedt_a', 'pedt_t'], default=None, help="the style of the input PML document; multiple normalization steps are applied")
parser.add_argument("--src", choices=['orig', 'treex'], default='orig', help="the source of the input PML document; multiple normalization steps are applied")

parser.add_argument("--no-add", action='store_true', help="do not add anything, just remove")

parser.add_argument("--clear-reffile", action='store_true', help="clear file references in 'reffile' elements")
parser.add_argument("--clear-schema", action='store_true', help="clear file references in the 'schema' element")
parser.add_argument("--sort-id-elems", action='store_true', help="sort subelements of the element with an 'id' attribute alphabetically")
parser.add_argument("--remove-extra-lm", action='store_true', help="remove LM element if reduntant")

parser.add_argument("--remove-empty", action='store_true', help="remove empty elements")
parser.add_argument("--remove-is-0", action='store_true', help="remove elements 'is_...' with the 0 value")
parser.add_argument("--remove-is-1", action='store_true', help="remove elements 'is_...' with the 1 value")

parser.add_argument("--remove-meta", action='store_true', help="remove 'meta' element under the root")
parser.add_argument("--remove-lang-sentence", action='store_true', help="remove '[eng,cze]_sentence' element")
parser.add_argument("--remove-root-nodetype", action='store_true', help="remove 'nodetype' element under '/tdata/trees/LM'")
parser.add_argument("--remove-p", action='store_true', help="remove phrase trees under 'p' elements")
parser.add_argument("--remove-annot-comment", action='store_true', help="remove 'annot_comment' elements")
parser.add_argument("--remove-m-alt-tag", action='store_true', help="remove 'm/alt_tag' elements")
parser.add_argument("--remove-functions", action='store_true', help="remove 'functions' elements")
parser.add_argument("--remove-pcedt-elem", action='store_true', help="remove 'pcedt' elements")
parser.add_argument("--remove-functor-change", action='store_true', help="remove the 'functor_change' elements")
parser.add_argument("--remove-anot-error", action='store_true', help="remove 'anot_error' elements")
parser.add_argument("--remove-form-change", action='store_true', help="remove the 'form_change' elements")
parser.add_argument("--remove-proto-lemma", action='store_true', help="remove 'proto_lemma' elements")
parser.add_argument("--remove-sentmod", action='store_true', help="remove 'sentmod' elements")
parser.add_argument("--remove-gram-sempos", action='store_true', help="remove 'gram/sempos' elements")
parser.add_argument("--discourse", choices=['collapse', 'remove'], default=None, help="handle discourse elements: 'collapse' replaces content with descendant element names, 'remove' deletes the element")
parser.add_argument("--remove-discourse-groups", action='store_true', help="remove 'discourse_group' elements")
parser.add_argument("--tidy-coref", action='store_true', help="tidy the result of coreferencen annotation process")

parser.add_argument("--clear-m-form", action='store_true', help="clear the m/form value")
parser.add_argument("--clear-m-tag", action='store_true', help="clear the m/tag value")
parser.add_argument("--clear-m-lemma", action='store_true', help="clear the m/lemma value")
parser.add_argument("--clear-afun", action='store_true', help="clear the afun value in elements with id attribute")
parser.add_argument("--clear-val-frame", action='store_true', help="clear the 'val_frame.rf' value in elements with id attribute")
parser.add_argument("--clear-t-lemma", action='store_true', help="clear the t_lemma value in elements with id attribute")
parser.add_argument("--clear-functor", action='store_true', help="clear the functor value in elements with id attribute")
parser.add_argument("--clear-deepord", action='store_true', help="clear the deepord value in elements with id attribute")
parser.add_argument("--clear-nodetype", action='store_true', help="clear the nodetype value in elements with id attribute")

parser.add_argument("--flatten-trees", choices=['ord', 'id'], default=None, help="flatten the trees (put all nodes directly under the root element), sorted by 'ord' or 'id'")


parser.add_argument("--keep-zone", type=str, default=None, help="only the specified zone will be kept; format: LANGCODE")
parser.add_argument("--keep-tree", type=str, default=None, help="only the specified tree will be kept; format: [apt]")
args = parser.parse_args()

if args.style is not None:
    if args.style == 'pedt_a':
        if args.src == 'orig':
            args.remove_p = True
            args.remove_annot_comment = True
            args.remove_m_alt_tag = True
            args.remove_functions = True
    if args.style == 'pedt_t':
        if args.src == 'orig':
            args.remove_lang_sentence = True
            args.remove_annot_comment = True
            args.remove_empty = True
            args.remove_pcedt_elem = True
            args.tidy_coref = True
            args.remove_functor_change = True
            args.remove_anot_error = True
        else:
            args.remove_root_nodetype = True
    if args.style == 'pdt_a':
        if args.src == 'orig':
            args.remove_meta = True
    if args.style == 'pdt_t':
        if args.src == 'orig':
            args.remove_lang_sentence = True
        else:
            args.remove_root_nodetype = True

xmlstring = sys.stdin.read()
m = re.search(r'\sxmlns="([^"]+)"', xmlstring)
ns = { "pml" : m.group(1) }
#xmlstring = re.sub(r'\sxmlns="[^"]+"', '', xmlstring, count=1)
root = ET.fromstring(xmlstring)

######## clear file references in 'reffile' elements #########
if args.clear_reffile:
    for reffile in root.findall('.//pml:reffile', ns):
        reffile.attrib["href"] = ""

######## clear file references in the 'schema' element #########
if args.clear_schema:
    for schemafile in root.findall('.//pml:schema', ns):
        schemafile.attrib["href"] = ""

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

########## delete redundant isolated LMs ###########

if args.remove_extra_lm:
    for par in root.findall('.//*[pml:LM]', ns):
        lms = par.findall('pml:LM', ns)
        if len(lms) == 1:
            par.remove(lms[0])
            for ch in lms[0].getchildren():
                par.append(ch)
            for k,v in lms[0].attrib.items():
                par.attrib[k] = v
            if lms[0].text is not None:
                par.text = lms[0].text

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
    pars = root.findall('.//pml:trees', ns)
    pars.extend(root.findall('.//pml:trees/pml:LM', ns))
    for par in pars:
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
                par.remove(ch)

############### delete annot comments #####################

if args.remove_annot_comment:
    for par in root.findall('.//*[pml:annot_comment]', ns):
        for ch in par.findall('./pml:annot_comment', ns):
            par.remove(ch)

############### delete m/alt_tag elements #####################

if args.remove_m_alt_tag:
    for par in root.findall('.//*[pml:alt_tag]', ns):
        if par.tag == "{" + ns["pml"] + "}m":
            for ch in par.findall('./pml:alt_tag', ns):
                par.remove(ch)

############### delete functions elements #####################

if args.remove_functions:
    for par in root.findall('.//*[pml:functions]', ns):
        for ch in par.findall('./pml:functions', ns):
            par.remove(ch)

############### delete empty struct elements (a, gram) #################

if args.remove_empty:
    for name in ['a', 'gram']:
        for par in root.findall(f'.//*[pml:{name}]', ns):
            for ch in par.findall(f'./pml:{name}', ns):
                if not ch.getchildren():
                    par.remove(ch)

############### delete elements (a, gram) #################

if args.remove_is_0:
    for name in ['is_generated', 'is_member', 'is_parenthesis']:
        for par in root.findall(f'.//*[pml:{name}]', ns):
            for ch in par.findall(f'./pml:{name}', ns):
                if ch.text.strip() == '0':
                    par.remove(ch)

############ delete elements (a, gram) with the 1 value #################

if args.remove_is_1:
    for name in ['is_member', 'is_extra_dependency', 'is_parenthesis_root']:
        for par in root.findall(f'.//*[pml:{name}]', ns):
            for ch in par.findall(f'./pml:{name}', ns):
                if ch.text.strip() == '1':
                    par.remove(ch)

############ tidy the artefacts of coreference annotation process #############

if args.tidy_coref:
    coref_elems = root.findall('.//pml:coref_text', ns)
    coref_elems.extend(root.findall('.//pml:bridging', ns))
    for coref_elem in coref_elems:
        # delete comments
        for par in coref_elem.findall('.//pml:comment/..', ns):
            for ch in par.findall('./pml:comment', ns):
                par.remove(ch)
        for par in coref_elem.findall('.//pml:str_comment/..', ns):
            for ch in par.findall('./pml:str_comment', ns):
                par.remove(ch)
        # delete src elements within coref_text
        for par in coref_elem.findall('.//pml:src/..', ns):
            for ch in par.findall('./pml:src', ns):
                par.remove(ch)
        # add informal-type elements with the SPEC value to the coref_text element, if missing
        for par in coref_elem.findall('.//pml:target-node.rf/..', ns):
            type_elems = par.findall('./pml:informal-type', ns)
            if not args.no_add and not type_elems:
                typeelem = ET.Element("informal-type")
                typeelem.text = "SPEC"
                par.append(typeelem)
        for par in coref_elem.findall('.//pml:target_node.rf/..', ns):
            type_elems = par.findall('./pml:type', ns)
            if not args.no_add and not type_elems:
                typeelem = ET.Element("type")
                typeelem.text = "SPEC"
                par.append(typeelem)
    # delete 'anaph_str_comment' attrs in t-nodes
    for par in root.findall('.//*[pml:anaph_str_comment]', ns):
        for ch in par.findall('./pml:anaph_str_comment', ns):
            par.remove(ch)

########## remove 'pcedt' elements #########

if args.remove_pcedt_elem:
    for par in root.findall('.//*[pml:pcedt]', ns):
        for ch in par.findall('./pml:pcedt', ns):
            par.remove(ch)

########## remove 'functor_change' elements #########

if args.remove_functor_change:
    for par in root.findall('.//*[pml:functor_change]', ns):
        for ch in par.findall('./pml:functor_change', ns):
            par.remove(ch)

########## remove 'anot_error' elements #########

if args.remove_anot_error:
    for par in root.findall('.//*[pml:anot_error]', ns):
        for ch in par.findall('./pml:anot_error', ns):
            par.remove(ch)

####### remove 'form_change' elements #########
if args.remove_form_change:
    for par in root.findall('.//*[pml:form_change]', ns):
        for ch in par.findall('./pml:form_change', ns):
            par.remove(ch)

########## remove 'proto_lemma' elements #########
if args.remove_proto_lemma:
    for par in root.findall('.//*[pml:proto_lemma]', ns):
        for ch in par.findall('./pml:proto_lemma', ns):
            par.remove(ch)

############ remove sentmod elements ###########
if args.remove_sentmod:
    for par in root.findall('.//*[pml:sentmod]', ns):
        for ch in par.findall('./pml:sentmod', ns):
            par.remove(ch)

############ remove gram elements that only contain sempos ###########
if args.remove_gram_sempos:
    for par in root.findall('.//*[pml:gram]', ns):
        for gram_elem in par.findall('./pml:gram', ns):
            # Get all children of the gram element
            children = gram_elem.getchildren()
            # Check if gram only contains a sempos element and nothing else
            if len(children) == 1 and children[0].tag == f"{{{ns['pml']}}}sempos":
                par.remove(gram_elem)

############ handle discourse elements ###########
if args.discourse is not None:
    for par in root.findall('.//*[pml:discourse]', ns):
        for discourse_elem in par.findall('./pml:discourse', ns):
            if args.discourse == 'remove':
                # Simply remove the entire discourse element
                par.remove(discourse_elem)
            elif args.discourse == 'collapse':
                # Get all descendant element names (excluding namespace prefix)
                descendant_names = set()
                for desc in discourse_elem.findall('.//*', ns):
                    # Extract local name from namespaced tag
                    if desc.tag.startswith(f"{{{ns['pml']}}}"):
                        local_name = desc.tag[len(f"{{{ns['pml']}}}"):]
                        descendant_names.add(local_name)
                
                # Clear all children and set text content to sorted descendant names
                for child in discourse_elem.getchildren():
                    discourse_elem.remove(child)
                
                if descendant_names:
                    discourse_elem.text = ' '.join(sorted(descendant_names))
                else:
                    discourse_elem.text = ""

############ remove discourse_group elements ###########
if args.remove_discourse_groups:
    for par in root.findall('.//*[pml:discourse_groups]', ns):
        for ch in par.findall('./pml:discourse_groups', ns):
            par.remove(ch)

############ clear m/form ###########
if args.clear_m_form:
    for m in root.findall('.//pml:m', ns):
        form_elems = m.findall('./pml:form', ns)
        for form_elem in form_elems:
            form_elem.text = ""

############ clear m/tag ###########
if args.clear_m_tag:
    for m in root.findall('.//pml:m', ns):
        tag_elems = m.findall('./pml:tag', ns)
        for tag_elem in tag_elems:
            tag_elem.text = ""

############ clear m/lemma ###########
if args.clear_m_lemma:
    for m in root.findall('.//pml:m', ns):
        lemma_elems = m.findall('./pml:lemma', ns)
        for lemma_elem in lemma_elems:
            lemma_elem.text = ""

############ clear afun ###########
if args.clear_afun:
    for elem in root.findall('.//*[@id]', ns):
        afun_elems = elem.findall('./pml:afun', ns)
        for afun_elem in afun_elems:
            afun_elem.text = ""

############ clear val_frame.rf ###########
if args.clear_val_frame:
    for elem in root.findall('.//*[@id]', ns):
        val_frame_elems = elem.findall('./pml:val_frame.rf', ns)
        for val_frame_elem in val_frame_elems:
            val_frame_elem.text = ""

############ clear t_lemma ###########
if args.clear_t_lemma:
    for elem in root.findall('.//*[@id]', ns):
        t_lemma_elems = elem.findall('./pml:t_lemma', ns)
        for t_lemma_elem in t_lemma_elems:
            t_lemma_elem.text = ""

############ clear functor ###########
if args.clear_functor:
    for elem in root.findall('.//*[@id]', ns):
        functor_elems = elem.findall('./pml:functor', ns)
        for functor_elem in functor_elems:
            functor_elem.text = ""

############ clear nodetype ###########
if args.clear_nodetype:
    for elem in root.findall('.//*[@id]', ns):
        nodetype_elems = elem.findall('./pml:nodetype', ns)
        for nodetype_elem in nodetype_elems:
            nodetype_elem.text = ""

############ flatten trees #####################
if args.flatten_trees is not None:
    # Iterate over all tree roots: elements with 's.rf' (a-files) or 'atree.rf' (t-files) subelement
    trees_elems = root.findall('.//pml:LM[pml:s.rf]', ns)
    trees_elems.extend(root.findall('.//pml:LM[pml:atree.rf]', ns))
    for trees_elem in trees_elems:
        # get all nodes in the tree
        nodes = trees_elem.findall('.//pml:LM[@id]', ns)
        # remove all their current children nodes
        for node in nodes:
            for ch in node.findall('./pml:children', ns):
                node.remove(ch)
        # replace the current children of the tree root with all nodes
        for ch in trees_elem.findall('./pml:children', ns):
            trees_elem.remove(ch)
        children_elem = ET.Element("children")
        
        # Define sorting functions
        def get_ord_value(node):
            ord_elem = node.find('./pml:ord', ns)
            # try 'deepord' (t-files) if 'ord' (a-files) is not present
            if ord_elem is None:
                ord_elem = node.find('./pml:deepord', ns)
            if ord_elem is not None and ord_elem.text is not None:
                try:
                    return int(ord_elem.text)
                except ValueError:
                    return float('inf')  # put nodes with invalid ord values at the end
            return float('inf')  # put nodes without ord at the end
        
        def get_id_value(node):
            id_attr = node.get('id', '')
            return id_attr
        
        # Sort nodes based on the specified criterion
        if args.flatten_trees == 'ord':
            sorted_nodes = sorted(nodes, key=get_ord_value)
        elif args.flatten_trees == 'id':
            sorted_nodes = sorted(nodes, key=get_id_value)
        
        for node in sorted_nodes:
            children_elem.append(node)
        trees_elem.append(children_elem)

############ clear deepord (must be after flatten_trees) ###########
if args.clear_deepord:
    for elem in root.findall('.//*[@id]', ns):
        deepord_elems = elem.findall('./pml:deepord', ns)
        for deepord_elem in deepord_elems:
            deepord_elem.text = ""

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
