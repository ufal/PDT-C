import xml.etree.ElementTree as ET
from xml.sax.saxutils import unescape
import sys
import re
import argparse

parser = argparse.ArgumentParser(description="A script to adjust PML file")
parser.add_argument("--layer", choices=['a', 't'])
args = parser.parse_args()

xmlstring = sys.stdin.read()
m = re.search(r'\sxmlns="([^"]+)"', xmlstring)
ns = { "pml" : m.group(1) }
#xmlstring = re.sub(r'\sxmlns="[^"]+"', '', xmlstring, count=1)
root = ET.fromstring(xmlstring)

def find_print_node_by_attr(attr_name):
    parts = attr_name.split('/')
    attr_name_ns = "/".join(['pml:'+part for part in parts])
    par_xpath = "/".join(['..']*len(parts))
    for node in root.findall(f'.//{attr_name_ns}/{par_xpath}', ns):
        attr = node.find(f'./{attr_name_ns}', ns)
        text = attr.text.rstrip()
        if text == "":
            ET.register_namespace('', ns["pml"])
            text = ET.tostring(attr, encoding='unicode').replace(' xmlns="http://ufal.mff.cuni.cz/pdt/pml/"', '')
            text = re.sub(r'>\s+', '>', text)
            text = re.sub(r'\s+<', '<', text)
            ET.register_namespace('pml', ns["pml"])
        print("\t".join([attr_name, node.attrib["id"], text]))

def find_missing_attr_in_node(attr_name, exclude_root=False):
    root_ids = []
    if exclude_root:
        trees_elem = root.find('.//pml:trees', ns)
        if trees_elem.attrib and "id" in trees_elem.attrib:
            root_ids.append(trees_elem.attrib["id"])
        roots = root.findall('.//pml:trees/*', ns)
        root_ids.extend([root_elem.attrib["id"] for root_elem in roots])
    parts = ['pml:'+part for part in attr_name.split('/')]
    attr_name_ns = "/".join(parts)
    attr_dir_ns = "/".join(parts[0:-1])
    par_xpath = "/".join(['..']*len(parts))
    for node in root.findall('.//*[@id]', ns):
        if node.tag == f'{{{ns["pml"]}}}reffile':
            continue
        node_id = node.attrib["id"]
        if node_id in root_ids:
            continue
        if node.find(f'./{attr_dir_ns}', ns) and node.find(f'./{attr_name_ns}', ns) is None:
            print("\t".join([f'missing {attr_name}', node_id]))

def check_ord_attr(attr_name):
    trees_elem = root.find('.//pml:trees', ns)
    if trees_elem.attrib and "id" in trees_elem.attrib:
        tree_elems = [trees_elem]
    else:
        tree_elems = trees_elem.getchildren()
    parts = attr_name.split('/')
    attr_name_ns = "/".join(['pml:'+part for part in parts])
    par_xpath = "/".join(['..']*len(parts))
    for tree_elem in tree_elems:
        ord_ids = []
        for node in tree_elem.findall(f'.//{attr_name_ns}/{par_xpath}', ns):
            node_id = node.attrib["id"]
            attr = node.find(f'./{attr_name_ns}', ns)
            ord_ids.append((int(attr.text), node_id))
        ord_ids = sorted(ord_ids, key=lambda x: x[0])
        for i, ord_id in enumerate(ord_ids):
            if i != ord_id[0]:
                print("\t".join([f'ord-error {attr_name}', ord_id[1], f"{ord_id[0]}>{i}" if ord_id[0] > i else f"{ord_id[0]}<{i}"]))
                break

def check_layerid_in_refs(attr_name):
    parts = attr_name.split('/')
    attr_name_ns = "/".join(['pml:'+part for part in parts])
    par_xpath = "/".join(['..']*len(parts))
    for node in root.findall(f'.//{attr_name_ns}/{par_xpath}', ns):
        node_id = node.attrib["id"]
        attr = node.find(f'./{attr_name_ns}', ns)
        attr_list = attr.getchildren()
        if attr_list:
            for item in attr_list:
                ref_parts = item.text.split("#")
                if len(ref_parts) < 2:
                    print("\t".join([f'missing layer id in {attr_name}', node_id]))
        else:
            ref_parts = attr.text.split("#")
            if len(ref_parts) < 2:
                print("\t".join([f'missing layer id in {attr_name}', node_id]))

def list_attr_values_of_node(attr_name, exclude_root=False):
    root_ids = []
    if exclude_root:
        trees_elem = root.find('.//pml:trees', ns)
        if trees_elem.attrib and "id" in trees_elem.attrib:
            root_ids.append(trees_elem.attrib["id"])
        roots = root.findall('.//pml:trees/*', ns)
        root_ids.extend([root_elem.attrib["id"] for root_elem in roots])
    attr_name_parts = ['pml:'+part for part in attr_name.split('/')]
    attr_dir = "/".join(attr_name_parts[0:-1])
    par_xpath = "/".join(['..']*len(attr_name_parts))
    for node in root.findall('.//*[@id]', ns):
        if node.tag == f'{{{ns["pml"]}}}reffile':
            continue
        node_id = node.attrib["id"]
        if node_id in root_ids:
            continue
        attr_dir_elem = node.find(f'./{attr_dir}', ns)
        if attr_dir_elem:
            item_elems = attr_dir_elem.findall(f'./pml:LM', ns)
            if item_elems:
                for item_elem in item_elems:
                    attr_elem = item_elem.find(f'./{attr_name_parts[-1]}', ns)
                    print("\t".join([f'values of {attr_name}', node_id, attr_elem.text if attr_elem is not None else "--MISSING--"]))
            else:
                attr_elem = attr_dir_elem.find(f'./{attr_name_parts[-1]}', ns)
                print("\t".join([f'values of {attr_name}', node_id, attr_elem.text if attr_elem is not None else "--MISSING--"]))

######## locate attribute on the a-layer #########
if args.layer == 'a':
    find_print_node_by_attr('functions')
    find_print_node_by_attr('m/alt_tag')
    check_ord_attr('ord')
    check_layerid_in_refs('ptree.rf')
    check_layerid_in_refs('p/terminal.rf')
    check_layerid_in_refs('p/nonterminals.rf')

######## locate attribute on the t-layer #########
if args.layer == 't':
    #find_print_node_by_attr('pcedt')
    #find_print_node_by_attr('functor_change')
    #find_print_node_by_attr('anot_error')
    find_print_node_by_attr('compar.rf')
    find_missing_attr_in_node('gram/sempos', exclude_root=True)
    find_missing_attr_in_node('gram', exclude_root=True)
    check_ord_attr('deepord')
    check_layerid_in_refs('atree.rf')
    check_layerid_in_refs('a/lex.rf')
    check_layerid_in_refs('a/aux.rf')
    check_layerid_in_refs('val_frame.rf')
    list_attr_values_of_node('coref_text/type')
    list_attr_values_of_node('bridging/type')
