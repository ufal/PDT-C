#!/usr/bin/env perl
use strict;
use warnings;

use Treex::PML;
use Treex::PML::Factory;
use Treex::PML::Instance;
use Udapi::Core::Document;

my $resources = "../../../../tred-extension/pdtc10/resources";

@ARGV >= 2 or die "Usage: $0 data_filelist data_path conllu_file\n";
my ($data_filelist, $data_basepath, $conllu_filename) = @ARGV;

my $conllu_doc = Udapi::Core::Document->new();
$conllu_doc->load_conllu($conllu_filename);
my @conllu_trees = $conllu_doc->trees;

Treex::PML::AddResourcePath(".", $resources);
delete $INC{"Treex/PML/Backend/PML.pm"}; Treex::PML::UseBackends("PML"); # Hack to reload pmlbackend_conf.xml from the current directory.
my $factory = Treex::PML::Factory->new();

open(my $data_filelist_file, "<", $data_filelist) or die "Cannot open file $data_filelist: $!";
while (my $pdt_file = <$data_filelist_file>) {
  chomp $pdt_file;
  my $pdt_doc = $factory->createDocumentFromFile($data_basepath . "/" . $pdt_file . ".a");
  my @pdt_trees = $pdt_doc->trees;

  die "Too little trees in the CoNLL-U file: $#pdt_trees vs $#conllu_trees" if $#pdt_trees > $#conllu_trees;

  for my $tree_index (0..$#pdt_trees) {
      my $pdt_root = $pdt_trees[$tree_index];
      my @pdt_nodes = ($pdt_root, sort {$a->get_order <=> $b->get_order} $pdt_root->descendants);
      # Skip empty PDT trees
      if ($#pdt_nodes == 0) {
        warn "Skipping an empty tree in file $pdt_file\n";
        next;
      }

      my $conllu_root = shift @conllu_trees;
      my @conllu_nodes = ($conllu_root, $conllu_root->descendants);
      die "Inconsistent number of nodes in tree $tree_index: $#pdt_nodes != $#conllu_nodes" if $#pdt_nodes != $#conllu_nodes;

      for my $n (1..$#pdt_nodes){
          my ($pdt_node, $conllu_node) = ($pdt_nodes[$n], $conllu_nodes[$n]);
          #die "Unexpected pdt->{ord} at $pdt_node->{id}: $n != ", $pdt_node->get_order if $pdt_node->get_order != $n;
          # ord attribute on the a-layer may have gaps (e.g. if a token from the w-layer is omitted on the m-layer),
          # so the condition above is commented out.
          # Luckily, the CoNLL-U files cannot have such bugs, so it is granted $conllu_nodes[$n]->ord == $n.
          die "Unexpected conllu_node->ord at $conllu_node->{id}: $n != ", $conllu_node->ord if $conllu_node->ord != $n;
          die "Inconsistent word form: ", $pdt_node->attr('m/form'), ' != ', $conllu_node->form if $pdt_node->attr('m/form') ne $conllu_node->form;
          $pdt_node->cut();
      }
      for my $n (reverse 1..$#pdt_nodes){ # The reverse order generates children sorted by ord
          my ($pdt_node, $conllu_node) = ($pdt_nodes[$n], $conllu_nodes[$n]);
          my $pdt_parent = $pdt_nodes[$conllu_node->parent->ord];
          #$pdt_node->set_parent($pdt_parent)
          # In Treex::PML (unlike in Treex), set_parent is not enough for changing the tree.
          # I think it should have been a private method _set_parent because it does not set lbrother and other internal pointers.
          # We have to use paste_on(), instead.
          $pdt_node->paste_on($pdt_parent, $conllu_node->ord);
          my ($afun, $suffix) = split /_/, $conllu_node->deprel, 2;
          $pdt_node->set_attr('afun', $afun);
          $pdt_node->set_attr('is_member', (($suffix//'') =~ /IsMember/ ? 1 : undef));
          $pdt_node->set_attr('is_parenthesis_root', (($suffix//'') =~ /IsParenthesisRoot/ ? 1 : undef));
      }
      #last if $tree_index > 2;
  }

  $pdt_doc->save($data_basepath . "/" . $pdt_file . ".a");
}

die "Too many trees in the CoNLL-U file: $#conllu_trees were left" if @conllu_trees;
