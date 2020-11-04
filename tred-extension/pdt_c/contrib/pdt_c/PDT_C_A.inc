# -*- cperl -*-

use strict;
BEGIN {
  import PML_A_View;
  $PDT_C_A::clause_coloring = 1;
  $PDT_C_A::clause_folding = 0;
}

sub detect {
  return (PML::SchemaDescription() =~ m/^PDT-C/ and PML::SchemaName() eq 'adata') ? 1 : 0;
}

sub allow_switch_context_hook {
  return 'stop' unless detect();
}

sub toggle_clause_coloring {
  return if $PDT_C_A::clause_folding;
  $PDT_C_A::clause_coloring = !$PDT_C_A::clause_coloring;
  ChangingFile(0);
}

sub toggle_clause_folding {
  return unless SchemaName() eq 'adata';
  $PDT_C_A::clause_folding = !$PDT_C_A::clause_folding;

  my $mapping = FileUserData('clauses');
  if ($PDT_C_A::clause_folding and not exists $this->{'_representant'}) {
    $this = $mapping->{$this->{id}};
  }
  if (not $PDT_C_A::clause_folding and exists $this->{'_representant'}) {
    $this = $this->{'_representant'};
  }

  ChangingFile(0);
}

sub switch_context_hook {
  my $cur_stylesheet = GetCurrentStylesheet();
  if ($cur_stylesheet ne 'PDT_C_A') {
    SetCurrentStylesheet('PDT_C_A');
    Redraw() if GUI();
  }
  return;
}

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  
  my @out;
  my @colors = qw(#ff00ff #ffa500 #0000ff #3cb371 #ff0000 #9932cc #00008b #006400 #8b0000 #008b8b);
  my $clause_mapping = FileUserData('clauses');
  
  foreach my $node (sort { $a->{ord} <=> $b->{ord} } grep { not exists $_->{'_representant'} } $tree->descendants) {
    my $token = join(" ", map { $_->{token} } ListV($node->attr('m/w')));
    my $form = $node->attr('m/form');
    my $color = $node->{clause_number} ? '-foreground=>'.$colors[$node->{clause_number} % 10] : '';
    my @refs = ($node);
    push @refs, $clause_mapping->{$node->{id}} if exists $clause_mapping->{$node->{id}};
    
    if ($form ne $token) {
      push @out, (['['.$token.']', @refs, '-over=>1']);
      if ($PDT_C_A::clause_coloring) {
        push @{$out[-1]}, $color if $color;
      } else {
        push @{$out[-1]}, '-foreground=>'.CustomColor('spell');
      }
    }
    
    push @out, ([$form, @refs]);
    if ($PDT_C_A::clause_coloring and $color) {
      push @{$out[-1]}, $color;
    }

    unless($node->attr('m/w/[-1]/no_space_after')){
      push @out, ([" ","space"]);
    }
  }
  
  return \@out;
}

sub get_nodelist_hook {
  my ($fsfile, $treeNo, $current) = @_;

  my $tree = $fsfile->tree($treeNo);
  prepare_clause_folding($tree) unless $tree->{'_clauses_ok'};
  prepare_labels($tree) unless $tree->{'_labels_ok'};

  my @out = sort { $a->{ord} <=> $b->{ord} } $tree->descendants;
  $current = $tree if not $current;

  foreach my $node (@out) {
    if (exists $node->{'_representant'}) {
      $node->{hide} = $PDT_C_A::clause_folding ? 0 : 1;
    } else {
      $node->{hide} = $PDT_C_A::clause_folding ? 1 : 0;
    }
  }

  $tree->{hide} = 0;
  return [ \($tree, @out), $current ];
}

sub TectogrammaticalTree {
  return unless SchemaName() =~ /^adata$/;
  return unless SwitchToTFile();
  my $id = $root->{id};
  my $this_id = $this->{id};
  if ($PDT_C_A::clause_folding and $this != $root) {
    $this_id = $this->{'_representant'}->{id};
  }
  SwitchContext('PDT_C_T');
  my $fsfile = $grp->{FSFile};

  #find current tree and new $this
  my $trees = $fsfile->treeList;
  my $treeNo = $fsfile->currentTreeNo+0;
  TREE: for (my $i=0; $i<=$#$trees; $i++) {
    foreach my $a_rf (PML_T::GetANodeIDs($trees->[$i])) {
      $a_rf =~ s/^.*\#//;
      if ($a_rf eq $id) {
        $treeNo = $i;
        last TREE;
      }
    }
  }

  TredMacro::GotoTree($treeNo+1); # changes $root
  my $node = $root;
  while ($node) {
    if (first { $_ eq $this_id } PML_T::GetANodeIDs($node)) {
      if ($PDT_C_T::mwe_folding and $node->{hide}) {
        $this = FileUserData('mwe')->{$node->{id}};
      } else {
        $this = $node;
      }
      last;
    }
  } continue {
    $node = $node->following;
  }
  ChangingFile(0);
  1;
}

sub prepare_labels {
  my $tree = shift;

  foreach my $node ($tree->descendants) {
    if (exists $node->{'_representant'}) {
      $node->{label} = '';
      next;
    }

    my $label = '';
    if (not $node->{afun} or ($node->{afun} =~ m/^Apos|^Coord/ and PML_A::ExpandCoord($node) == 0)) {
      $label .= '#{customerror}!!';
    } else {
      $label .= '#{customafun}';
    }
    $label .= $node->{afun};

    if ($node->{is_member}) {
      my $p = $node->parent;
      $p = $p->parent while $p and $p->{afun} =~ m/^Aux[CP]$/;
      if ($p and $p->{afun} =~ m/^(Ap)os|(Co)ord/) {
        $label .= "_#{customcoappa}\${is_member=$1$2}";
      } else {
        $label .= "_#{customerror}\${is_member=ERR}";
      }
    }

    if ($node->{'is_parenthesis_root'}) {
      $label .= '#{customcoappa}_${is_parenthesis_root=Pa}';
    }

    $node->{label} = $label;
  }

  $tree->{'_labels_ok'} = 1;
}

sub _find_representant {
  my ($num, $group) = @_;

  my @parents;
  my $parent;
  my %roots;
  foreach my $node (@$group) {
    if ($node->parent->{'clause_number'} != $num) {
      push @parents, $node->parent unless exists $roots{$node->parent->{id}};
      push @{$roots{$node->parent->{id}}}, $node;
    }
  }

  if (scalar(@parents) == 1) {
    $parent = shift @parents;
  } else {
    my @new_parents;
    for my $id (keys %roots) {
      my @tmp = ();
      foreach my $node (@{$roots{$id}}) {
        my @nodes = ($node);
        while (@nodes and not grep { $_->{afun} !~ m/^(?:Coord|Aux|Apos)/ } @nodes) {
          @nodes = grep { $_->{'clause_number'} == $num } map { $_->children } @nodes;
        }
        push @tmp, $node if @nodes;
      }
      push @new_parents, $tmp[0]->parent if @tmp;
    }
    
    if (scalar(@new_parents) == 1) {
      $parent = shift @new_parents;
    } else {
      my @search = scalar(@new_parents) ? @new_parents : @parents;
      my $min_depth = 999;
      my $min_p;

      foreach my $item (@search) {
        my $depth = 0;
        my $p = $item;
        while ($p->parent) {
          $depth++;
          $p = $p->parent;
        }

        if ($depth < $min_depth) {
          $min_p = $item;
          $min_depth = $depth;
        }
      }

      $parent = $min_p;
    }
  }

  my @roots = @{$roots{$parent->{id}}};

  my $r_node;
  if (scalar(@roots) == 1) {
    $r_node = $roots[0];
  } else {
    my @members = grep { $_->{is_member} } @roots;
    if (scalar @members) {
      $r_node = $members[0];
    } else {
      my @noaux = grep { $_->{afun} !~ m/^(?:Aux|Coord|Apos)/ } @roots;
      if (scalar @noaux) {
        $r_node = $noaux[0];
      } else {
        $r_node = $roots[0];
      }
    }
  }

  my $member = first { $_->{'clause_number'} == $num } GetCoordMembers($r_node);
  return $member ? $member : $r_node;
}

sub prepare_clause_folding {
  my $tree = shift;
  my $mapping = FileUserData('clauses') || {};
  my %groups;
  my %clause_nodes;

  foreach my $node (sort { $a->{ord} <=> $b->{ord} } $tree->descendants) {
    push @{$groups{$node->{'clause_number'}}}, $node if $node->{'clause_number'} > 0;
  }

  while (my ($num, $group) = each %groups) {
    my $label = $group->[0]->attr('m/form');
    for (my $i = 1; $i < scalar(@$group); $i++) {
      unless ($group->[$i-1]->attr('m/w/no_space_after') and ($group->[$i]->{ord} - $group->[$i-1]->{ord} == 1)) {
        $label .= ' ';
      }
      $label .= $group->[$i]->attr('m/form');
    }
    
    my $clause_node = NewSon($tree);
    $clause_node->set_type_by_name($tree->type()->schema(), 'a-node.type');
    $clause_node->{id} = $tree->{id}.'-clause'.$num;
    $clause_node->{m}->{form} = $label;
    $clause_node->{afun} = '';
    $clause_node->{'clause_number'} = $num;
    $clause_node->{ord} = 0;
    AddToNodeHash($clause_node->{id}, $clause_node);

    foreach my $node (@$group) {
      $mapping->{$node->{id}} = $clause_node;
      $clause_node->{ord} += $node->{ord};
    }
    $clause_node->{ord} = 1000 + $clause_node->{ord} / scalar @$group;

    $clause_nodes{$num} = [$clause_node, _find_representant($num, $group)];
  }

  while (my ($num, $clause) = each %clause_nodes) {
    my ($parent) = GetEParents($clause->[1], \&DiveAuxCP);
    if (not $parent) {
      $parent = $clause->[1]->parent;
      while ($parent->parent and $parent->{afun} =~ m/^(?:Coord|Apos|Aux[CP])$/) {
        $parent = $parent->parent;
      }
    }

    if (not $parent or not $parent->{'clause_number'} or $parent->{'clause_number'} == $num) {
      CutPaste($clause->[0], $tree);
    } else {
      my $candidate = $clause_nodes{$parent->{'clause_number'}}->[0];
      while ( grep { $_ == $candidate } ($clause->[0], $clause->[0]->descendants) ) {
        $candidate = $candidate->parent;
      }
      CutPaste($clause->[0], $candidate);
    }

    $clause->[0]->{'_representant'} = $clause->[1];
  }

  FileUserData('clauses', $mapping);
  PDT_C_T::normalize_ordering($tree, 'ord');
  $tree->{'_clauses_ok'} = 1;
}

1;

