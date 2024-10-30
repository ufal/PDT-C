# -*- cperl -*-

# TrEd macros for displaying PDT-C tectogrammatical files
# Modified from PDT 3.5 extension by Jiri Mirovsky, mirovsky at ufal.mff.cuni.cz

BEGIN {
  import PML_T_View;
  $PDT_C_T::mwe_folding = 0;
  $PDT_C_T::show_legend = 0;
  $PDT_C_T::toggle_displaying_discourse = 1; # this way the setting remains when different files are opened while listing among PML-TQ results
  $PDT_C_T::toggle_displaying_coref_text = 1;
  $PDT_C_T::toggle_displaying_bridging = 1;
  $PDT_C_T::toggle_displaying_t_lemma_trans = 0;
  $PDT_C_T::toggle_displaying_a_nodes_grams = 0;
  $PDT_C_T::toggle_displaying_t_root_id = 0;
  $PDT_C_T::toggle_displaying_tfa = 0;
  CustomColor('arrow_bridging', '#00ccff');
  CustomColor('arrow_discourse', '#ff710c');
  $PDT_C_T::paragraph_separator = "\n";
}

sub node_release_hook     { return 1; }
sub enable_attr_hook      { return 1; }
sub enable_edit_node_hook { return 1; }

use strict;
# use warnings;
# no warnings qw(redefine);

# use vars qw($this $root $grp);

=item TODO

Essential:
  - display arrows that start in an mwe in the mwe-folded mode
Non-essential:
  - add clause-folding mode on t-layer
  - shorter arrows (ending at the big circles just like in PDT 2.5 mode)

=cut

#This hash and its use in after_redraw_hook() is needed to keep constant
#order of annotators between trees in files that include multiple
#annotators' annotations. 
our %annotator;

# Numerical positions of roots of all trees. Drawing of arrows is a bit faster.
# But the main reason is that (while using the standard methods) the SVG print
# crashes on coreference arrows leading to nodes in diferrent trees.
# our %root_index;

sub detect {
  return ((PML::SchemaDescription() // "") =~ m/^PDT-C/
          and (PML::SchemaName() // "") eq 'tdata') ? 1 : 0;
}

sub allow_switch_context_hook {
  return 'stop' unless detect();
}


sub set_context_trees {
  my ($before, $after) = @_;
  # Two ways of setting the size of the context, whichever may work:
  # Way 1:
  SetMinorModeData('Show_Neighboring_Trees', 'context_before', $before);
  SetMinorModeData('Show_Neighboring_Trees', 'context_after', $after);
  # Way 2:
  TrEd::MinorMode::Show_Neighboring_Trees::configure($before, $after);
}


sub set_context_sentences {
  my ($before, $after) = @_;
  # Two ways of setting the size of the context, whichever may work:
  # Way 1:
  SetMinorModeData('Show_Neighboring_Sentences', 'context_before', $before);
  SetMinorModeData('Show_Neighboring_Sentences', 'context_after', $after);
  # Way 2:
  TrEd::MinorMode::Show_Neighboring_Sentences::configure($before, $after);
}

sub switch_context_hook {
  set_context_trees(1,1);
  EnableMinorMode('Show_Neighboring_Sentences');
  set_context_sentences(2,2);
  DisableMinorMode('Show_Neighboring_Trees');

  my $cur_stylesheet = GetCurrentStylesheet();
  if ($cur_stylesheet ne 'PDT_C_T') {
    SetCurrentStylesheet('PDT_C_T');
    Redraw() if GUI();
  }
  return;
}

sub pre_switch_stylesheet_hook {
  my ($previous, $next) = @_;
  if ($next =~ /Discourse/) {
    EnableMinorMode('Show_Neighboring_Trees');
    $PDT_C_T::toggle_displaying_discourse = 1;
    $PDT_C_T::toggle_displaying_coref_text = 1;
    $PDT_C_T::toggle_displaying_bridging = 1;
  }
  else {
    DisableMinorMode('Show_Neighboring_Trees');    
    $PDT_C_T::toggle_displaying_discourse = 0;
    $PDT_C_T::toggle_displaying_coref_text = 0;
    $PDT_C_T::toggle_displaying_bridging = 0;
  }
}


sub toggle_clause_coloring {
  PDT_C_A::toggle_clause_coloring();
}

sub toggle_legend {
  $PDT_C_T::show_legend = !$PDT_C_T::show_legend;
  ChangingFile(0);
}

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  my ($a_tree) = GetANodes($tree);
  return unless ($a_tree);
  
  my $mwe_mapping = FileUserData('mwe');
  
  my $node = $tree->following;
  my %refers_to;
    while ($node) {
    foreach (GetANodeIDs($node)) {
      push @{$refers_to{$_}}, $node;
      push(@{$refers_to{$_}}, $mwe_mapping->{$node->{id}}) if exists $mwe_mapping->{$node->{id}};
    }
    $node = $node->following;
  }
  
  $node = $a_tree->following;
  my @sent=();
  while ($node) {
    push @sent,$node if not exists $node->{'_representant'};
    $node=$node->following();
  }
  
  my @out;
  my @colors = do { no warnings 'qw';
                    qw(#ff00ff #ffa500 #0000ff #3cb371 #ff0000 #9932cc
                          #00008b #006400 #8b0000 #008b8b) };
  foreach $node (sort { $a->{ord} <=> $b->{ord} } @sent) {
    my $token = join(" ", map { $_->{token} } ListV($node->attr('m/w')));
    my $form = $node->attr('m/form');
    push @out, ([$form, @{$refers_to{$node->{id}} || []}, 'anode:'.$node->{id}]);
    if ($PDT_C_A::clause_coloring and $node->{clause_number}) {
      push @{$out[-1]}, '-foreground=>'.$colors[$node->{clause_number} % 10];
    }
    unless ($node->attr('m/w/[-1]/no_space_after')) {
      push @out, ([" ","space"]);
    }
  }

  # paragraph separation
  if (my $separator = $PDT_C_T::paragraph_separator) {
    if ($separator eq "\n") {
      # create an empty line if a new paragraph starts after the sentence
      # "\n" is put at the end of the last sentence of the ending paragraph so that the arrow marking the actual sentence
      # does not point to an empty line
      my $nextTree = $fsfile && $fsfile->tree($treeNo+1);
      if ($nextTree && $nextTree->{id}) {
        if ($nextTree->{id}=~/s1[A-Z]*$/) { # next tree starts a new paragraph
          push @out, [$separator, 'space'];
        }
      }
    }
    else {
    # if the separator is not "\n", let us put it in front of the sentence (if it starts the new paragraph)
      if (my $separator = get_paragraph_separator()) {
        my $actual_tree = $fsfile && $fsfile->tree($treeNo);
        if ($actual_tree && $actual_tree->{id}) {
          if ($actual_tree->{id}=~/s1[A-Z]*$/) { # the actual tree starts a new paragraph
            unshift @out, [$separator, 'space'];
          }
        }
      }
    }
  }

  return \@out;
}

sub get_nodelist_hook {
  my ($fsfile, $treeNo, $current) = @_;

  my $tree = $fsfile->tree($treeNo);
  prepare_mwe_folding($tree) if not $tree->{'_mwe_ok'};
  prepare_styles($tree) if not $tree->{'_styles_ok'};

  my @out = sort { $a->{deepord} <=> $b->{deepord} } ($tree, $tree->descendants);
  $current = $tree if not $current or $current->root != $tree;

  return [ \@out, $current ];
}

sub draw_legend {
  my $canvas = shift;

  $canvas->createRectangle(10, 10, 810, 265, -fill => 'LightYellow1', -outline => 'black', -width => 1);
  my @font_conf = (-anchor => 'w', -font => 'sans 10', -width => 230);
  my $stipples = TrEd::NodeGroups::dense_stipples($grp);

  # First column
  $canvas->createOval(25, 25, 32, 32, -fill => CustomColor('tnode'), -outline => 'black', -width => 1);
  $canvas->createText(40, 28, @font_conf, -text => 'Standard node or Root');
  $canvas->createOval(25, 45, 32, 52, -fill => CustomColor('tfa_t'), -outline => 'black', -width => 1);
  $canvas->createText(40, 48, @font_conf, -text => 'Non-contrastive contextually bound node');
  $canvas->createOval(25, 65, 32, 72, -fill => CustomColor('tfa_f'), -outline => 'black', -width => 1);
  $canvas->createText(40, 68, @font_conf, -text => 'Contextually non-bound node');
  $canvas->createOval(25, 85, 32, 92, -fill => CustomColor('tfa_c'), -outline => 'black', -width => 1);
  $canvas->createText(40, 88, @font_conf, -text => 'Contrastive contextually bound node');

  $canvas->createLine(25, 103, 270, 103, -fill => 'grey');

  $canvas->createOval(25, 115, 32, 122, -fill => CustomColor('tnode'), -outline => 'black', -width => 1);
  $canvas->createText(40, 118, @font_conf, -text => 'Node with a surface form');
  $canvas->createRectangle(25, 135, 32, 142, -fill => CustomColor('tnode'), -outline => 'black', -width => 1);
  $canvas->createText(40, 138, @font_conf, -text => 'Generated node');

  # Second column
  @font_conf = (-anchor => 'w', -font => 'sans 10', -width => 160);

  $canvas->createOval(312, 38, 319, 45, -fill => CustomColor('tnode_coord'), -outline => 'black', -width => 1);
  $canvas->createOval(295, 21, 336, 62, -outline => CustomColor('line_coord'), -width => 1, -dash => [5,5]);
  $canvas->createText(344, 41, @font_conf, -text => 'Coordination/Apposition root');
  $canvas->createRectangle(298, 73, 332, 107, -fill => 'white', -outline => undef);
  $canvas->createRectangle(300, 75, 330, 105, -fill => 'red', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(344, 90, @font_conf, -text => 'Multiword entity');
  $canvas->createPolygon(316, 120, 322.9, 132, 309.1, 132, -fill => CustomColor('mwe_node'), -outline => 'black');
  $canvas->createText(344, 127, @font_conf, -text => 'Folded multiword entity');

  # Third column
  @font_conf = (-anchor => 'w', -font => 'sans 10', -width => 240);

  # arrows
  $canvas->createLine(530, 28, 580, 28, -arrow => 'last', -arrowshape => [16, 18, 3], -fill => CustomColor('arrow_grammatical'));
  $canvas->createText(588, 28, @font_conf, -text => 'Grammatical coreference');
  $canvas->createLine(530, 48, 580, 48, -arrow => 'last', -arrowshape => [16, 18, 3], -fill => CustomColor('arrow_textual'));
  $canvas->createText(588, 48, @font_conf, -text => 'Textual coreference');
  $canvas->createLine(530, 68, 580, 68, -arrow => 'last', -arrowshape => [16, 18, 3], -fill => CustomColor('arrow_compl'));
  $canvas->createText(588, 68, @font_conf, -text => 'Second dependency');

  # edges
  $canvas->createLine(530, 88, 580, 88, -fill => CustomColor('line_normal'), -width => 2);
  $canvas->createText(588, 88, @font_conf, -text => 'Dependency');
  $canvas->createLine(530, 108, 580, 108, -fill => CustomColor('line_coord'), -width => 1);
  $canvas->createText(588, 108, @font_conf, -text => 'Non-dependency (paratactic structure)');
  $canvas->createLine(530, 128, 580, 128, -fill => CustomColor('line_comm'), -width => 2);
  $canvas->createText(588, 128, @font_conf, -text => 'Non-dependency (shared modifier)');
  $canvas->createLine(530, 148, 580, 148, -fill => CustomColor('line_normal'), -width => 1, -dash => [2, 4]);
  $canvas->createText(588, 148, @font_conf, -text => 'Non-dependency (other)');

  $canvas->createLine(25, 163, 795, 163, -fill => 'gray');
  
  # MWE types
  $canvas->createText(25, 182, -anchor => 'w', @font_conf, -text => 'Multiword entity types:');
  @font_conf = (-anchor => 'w', -font => 'sans 10', -width => 108);

  # First column
  $canvas->createRectangle(23, 198, 47, 222, -fill => 'white', -outline => undef);
  $canvas->createRectangle(25, 200, 45, 220, -fill => 'red', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(59, 210, @font_conf, -text => 'Semlex');
  $canvas->createRectangle(23, 228, 47, 252, -fill => 'white', -outline => undef);
  $canvas->createRectangle(25, 230, 45, 250, -fill => 'olive drab', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(59, 240, @font_conf, -text => 'Person');

  # Second column
  $canvas->createRectangle(180, 198, 200, 222, -fill => 'white', -outline => undef);
  $canvas->createRectangle(182, 200, 202, 220, -fill => 'hot pink', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(216, 210, @font_conf, -text => 'Institution');
  $canvas->createRectangle(180, 228, 200, 252, -fill => 'white', -outline => undef);
  $canvas->createRectangle(182, 230, 202, 250, -fill => 'turquoise1', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(216, 240, @font_conf, -text => 'Location');

  # Third column
  $canvas->createRectangle(337, 198, 361, 222, -fill => 'white', -outline => undef);
  $canvas->createRectangle(339, 200, 359, 220, -fill => 'plum', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(373, 210, @font_conf, -text => 'Object');
  $canvas->createRectangle(337, 228, 361, 252, -fill => 'white', -outline => undef);
  $canvas->createRectangle(339, 230, 359, 250, -fill => 'light slate blue', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(373, 240, @font_conf, -text => 'Address');

  # Fourth column
  $canvas->createRectangle(494, 198, 518, 222, -fill => 'white', -outline => undef);
  $canvas->createRectangle(496, 200, 516, 220, -fill => 'lime green', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(530, 210, @font_conf, -text => 'Time');
  $canvas->createRectangle(494, 228, 518, 252, -fill => 'white', -outline => undef);
  $canvas->createRectangle(496, 230, 516, 250, -fill => '#8aa3ff', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(530, 240, @font_conf, -text => 'Biblio');

  # Fifth column
  $canvas->createRectangle(651, 198, 671, 222, -fill => 'white', -outline => undef);
  $canvas->createRectangle(653, 200, 673, 220, -fill => '#8a535c', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(687, 210, @font_conf, -text => 'Foreign');
  $canvas->createRectangle(651, 228, 671, 252, -fill => 'white', -outline => undef);
  $canvas->createRectangle(653, 230, 673, 250, -fill => 'orange1', -stipple => $stipples->[0], -outline => undef);
  $canvas->createText(687, 240, @font_conf, -text => 'Number');
}


# colors for discourse groups:
my $pa_colors=["#CF9", "#FDA", "#9FF", "#FAF", "#AFA", "#AAF", "#FAA"];
my $ref_array_groups_sorted;

sub after_redraw_hook {
  my $treeview = shift;
  PML_T::after_redraw_hook($treeview);

  if ($PDT_C_T::show_legend) {
    draw_legend($treeview->realcanvas());
  }

  # mwes:
  if ($PDT_C_T::mwe_folding eq 0) { # mwes displayed as groups of nodes
    # The same colours as those used in the annotation tool sem-ann, 
    # except for red for 'real mwes' - i.e. SemLex entries other than NEs
    my %mwe_colours = ( 
      lexeme      => 'red', #originally 'maroon'
      person      => 'olive drab',
      institution => 'hot pink',
      location    => 'turquoise1',
      object      => 'plum',
      address     => 'light slate blue',
      time        => 'lime green',
      biblio      => '#8aa3ff',
      foreign     => '#8a535c',
      number      => 'orange1'
    );
    my @stipples = (qw(dense1 dense2 dense5 dense6));

    my @groups;
    my @group_colors;
    my @group_stipples;
    
    foreach my $snode ( ListV( $root->attr('mwes') || ()) ) {
      my $name = $snode->{annotator};
      $annotator{$name} = (keys %annotator) + 1 if not $annotator{$name};
      my $mwe_type = $snode->{type};
      my @group = map { GetNodeByID($_) } ListV( $snode->{'tnode.rfs'} );
      push @groups, [@group];
      push @group_colors, $mwe_colours{$mwe_type};
      push @group_stipples, $stipples[ $annotator{$name} -1 ];
    }
    TrEd::NodeGroups::draw_groups(
      $grp,
      \@groups,
      {
        colors   => \@group_colors,
        stipples => \@group_stipples
      }
    );
  } # mwes
  
  # discourse groups:
  if (CurrentFile() && get_display_discourse() eq '1') {

    return if !defined $root; # no warnings when using Tred's "reload current file" button

    my %groups;
    for my $node (GetDisplayedNodes()) {
      my @node_groups = ListV($node->attr('discourse_groups'));
      foreach my $node_group (@node_groups) {
        my $group = $node_group->{'id'};
        if (defined $group) {
          push (@{$groups{$group}}, $node);
        }
      }
    }

    my @groups_ids = keys %groups;
    if (@groups_ids) { # there are groups on the screen

      my @array_groups_sorted_ids = sort {$a<=>$b} @groups_ids;
      my @a_colors;
      my $ord=0;
      my $number_of_colors=scalar(@$pa_colors);
      foreach my $group_id (@array_groups_sorted_ids) { # define colors for the displayed groups based on their ids
        $a_colors[$ord]=$$pa_colors[$group_id % $number_of_colors];
        $ord++;
      }
      my $ref_array_groups_sorted = [ map { $groups{$_} } @array_groups_sorted_ids ];
      my $pa_stipples = TrEd::NodeGroups::dense_stipples($grp);
      TrEd::NodeGroups::draw_groups(
        $grp,
        $ref_array_groups_sorted,
        {
          colors  => \@a_colors,
          stipples => $pa_stipples,
          x_shift => 0,
        }
      );
    }
  } # discourse groups

}

my %pdtb3_short = (
      "Comparison.Concession.Arg1-as-denier" => "Conc.Arg1asDenier",
      "Comparison.Concession.Arg2-as-denier" => "Conc.Arg2asDenier",
      "Comparison.Concession+SpeechAct.Arg2-as-denier+SpeechAct" => "Cons+SA.Arg2asDen",
      "Comparison.Contrast" => "Contrast",
      "Comparison.Similarity" => "Similarity",
      "Contingency.Cause.Reason" => "Cause.Reason",
      "Contingency.Cause.Result" => "Cause.Result",
      "Contingency.Cause+Belief.Reason+Belief" => "Cause+B.Reason+B",
      "Contingency.Cause+Belief.Result+Belief" => "Cause+B.Result+B",
      "Contingency.Cause+SpeechAct.Reason+SpeechAct" => "Cause+SA.Reason+SA",
      "Contingency.Cause+SpeechAct.Result+SpeechAct" => "Cause+SA.Result+SA",
      "Contingency.Negative-cause.NegResult" => "NegCause.NegResult",
      "Contingency.Condition.Arg1-as-cond" => "Cond.Arg1asCond",
      "Contingency.Condition.Arg2-as-cond" => "Cond.Arg2asCond",
      "Contingency.Condition+SpeechAct" => "Cond+SA",
      "Contingency.Negative-condition.Arg1-as-negCond" => "NegCond.Arg1asNegCond",
      "Contingency.Negative-condition.Arg2-as-negCond" => "NegCond.Arg2asNegCond",
      "Contingency.Negative-condition+SpeechAct" => "NegCond+SA",
      "Contingency.Purpose.Arg1-as-goal" => "Purp.Arg1asGoal",
      "Contingency.Purpose.Arg2-as-goal" => "Purp.Arg2asGoal",
      "Expansion.Conjunction" => "Conjunction",
      "Expansion.Disjunction" => "Disjunction",
      "Expansion.Equivalence" => "Equivalence",
      "Expansion.Exception.Arg1-as-excpt" => "Except.Arg1asExcpt",
      "Expansion.Exception.Arg2-as-excpt" => "Except.Arg2asExcpt",
      "Expansion.Instantiation.Arg1-as-instance" => "Inst.Arg1asInst",
      "Expansion.Instantiation.Arg2-as-instance" => "Inst.Arg2asInst",
      "Expansion.Level-of-detail.Arg1-as-detail" => "Level.Arg1asDetail",
      "Expansion.Level-of-detail.Arg2-as-detail" => "Level.Arg2asDetail",
      "Expansion.Manner.Arg1-as-manner" => "Manner.Arg1asManner",
      "Expansion.Manner.Arg2-as-manner" => "Manner.Arg2asManner",
      "Expansion.Substitution.Arg1-as-subst" => "Subst.Arg1asSubst",
      "Expansion.Substitution.Arg2-as-subst" => "Subst.Arg2asSubst",
      "Temporal.Asynchronous.Precedence" => "Asynch.Prec",
      "Temporal.Asynchronous.Succession" => "Asynch.Succ",
      "Temporal.Synchronous" => "Synchronous",
      "IGNORE" => "IGNORE",
);

sub shorten_PDTB3_sense {
  my $sense = shift;
  my $short = $pdtb3_short{$sense};
  if (!$short) {
    $short = $sense;
  }
  return $short;
}

sub AnalyticalTree {
  return unless SchemaName() eq 'tdata';
  return unless SwitchToAFile();
  my $t_root = $root;
  my $t_node = exists $this->{'mwe_root'} ? $this->{'mwe_root'} : $this;
  DisableMinorMode('Show_Neighboring_Trees');
  SwitchContext('PDT_C_A');
  my $fsfile = $grp->{FSFile};

  #find current tree and new $this
  my $trees = $fsfile->treeList;
  my $treeNo = $fsfile->currentTreeNo+0;
  TREE: for (my $i=0; $i<=$#$trees; $i++) {
    foreach my $a_rf (GetANodeIDs($t_root)) {
      $a_rf =~ s/^.*?#//;
      if ($trees->[$i]->{id} eq $a_rf) {
	      $treeNo = $i;
	      last TREE;
      }
    }
  }

  TredMacro::GotoTree($treeNo+1); # changes $root and $this
  my $a_ids = GetNodeHash($fsfile);
  my $first =
    first {
      ref($a_ids->{$_}) and ($a_ids->{$_}->root == $root) ? 1 : 0
    } GetANodeIDs($t_node);
  my $a_node = $a_ids->{$first};
  if ($PDT_C_A::clause_folding) {
    if ($a_node->{'clause_number'}) {
      $a_node = FileUserData('clauses')->{$a_node->{id}};
    } else {
      $a_node = $a_node->root;
    }
  }
  $this = $a_node;
  ChangingFile(0);
  return 1;
}

sub expand_ordering {
  my $tree = shift;
  my $attr = shift || 'deepord';
  foreach my $node ($tree->descendants) {
    $node->{$attr} *= 1000;
  }
}

sub normalize_ordering {
  my $tree = shift;
  my $attr = shift || 'deepord';
  my $index = 1;
  foreach my $node ( sort { $a->{$attr} <=> $b->{$attr} } $tree->descendants ) {
    $node->{$attr} = $index++;
  }
}

sub prepare_mwe_folding {
  my $tree = shift;
  my $mapping = FileUserData('mwe') || {};
  expand_ordering($tree);
  my @mwe_nodes = ();

  foreach my $mwe (ListV($tree->{mwes})) {
    my $mwe_node = NewSon($tree);
    $mwe_node->set_type_by_name($tree->type()->schema(), 't-node.type');
    $mwe_node->{id} = $mwe->{id};
    $mwe_node->{type} = $mwe->{type};
    AddToNodeHash($mwe_node->{id}, $mwe_node);

    if ($mwe->{'basic-form'}) {
      $mwe_node->{label} = $mwe->{'basic-form'};
    } else {
      # basic-form was not added manualy -> let's create it from a-layer
      # First, get corresponding a-nodes
      my @a_nodes = sort { $a->{ord} <=> $b->{ord} } map { GetANodes(GetNodeByID($_)) } ListV($mwe->{'tnode.rfs'});
      # add AuxX and AuxG (interpunction) a-nodes to the list
      for (my $i = 0; $i < @a_nodes; $i++) {
        my $a_node = $a_nodes[$i];
        my $next_in_mwe = $a_nodes[$i+1];
        my $next_by_ord = NextNodeLinear($a_node, "ord");
        if ($next_in_mwe                                # $i is not the last
            and $a_node->{ord}+1 < $next_in_mwe->{ord}  # there is a gap after it
            and $next_by_ord->{afun} =~ /^Aux[XG]$/     # with interpunction within
            and ($next_by_ord->parent == $a_node        # governed by either left
              or $next_by_ord->parent == $next_in_mwe)  # or right a-node node
           ) {
          splice(@a_nodes, $i+1, 0, $next_by_ord);
        }
      }
      # add AuxX nad AuxG at the left and right from MWE
      my $next = NextNodeLinear($a_nodes[-1], "ord");
      if ($next and $next->{afun} =~ /^Aux[XG]$/
          and $next->parent == $a_nodes[-1]) {
        push(@a_nodes, $next);
      }
      my $prev = PrevNodeLinear($a_nodes[0], "ord");
      if ($next and $next->{afun} =~ /^Aux[XG]$/
          and $next->parent == $a_nodes[0]) {
        push(@a_nodes, $next);
      }

      # Second, assemble the sentence
      my $label = $a_nodes[0]->attr('m/form');
      for (my $i = 1; $i <= $#a_nodes; $i++) {
        unless ($a_nodes[$i-1]->attr('m/w/no_space_after') and ($a_nodes[$i]->{ord} - $a_nodes[$i-1]->{ord} == 1)) {
          $label .= ' ';
        }
        $label .= $a_nodes[$i]->attr('m/form');
      }
      $mwe_node->{label} = $label;
    }

    foreach my $id (ListV($mwe->{'tnode.rfs'})) {
      $mapping->{$id} = $mwe_node;
    }

    push @mwe_nodes, [$mwe_node, $mwe];
  }

  foreach my $mwe (@mwe_nodes) {
    my @roots = ();
    my $root;
    my @children = ();

    foreach my $node ( map { GetNodeByID($_) } ListV($mwe->[1]->{'tnode.rfs'}) ) {
      if (not exists($mapping->{$node->parent->{id}}) or $mapping->{$node->parent->{id}} != $mwe->[0]) {
        # If the MWE is a foreign phrase (i.e. node #Forn with one-level-children representing the phrase),
        # hide the #Forn node together with others
        # It is supposed (and not tested) that WHOLE foreign phrase is marked as a MWE.
        if ($node->parent->{nodetype} eq "list" and $node->parent()->{t_lemma} eq "#Forn") {
          # root is #Forn (one level higher than $node)
          push @roots, $node->parent();
          # and #Forn becomes part of a MWE, so it is affected by collapsing
          $mapping->{$node->parent()->{id}} = $mwe->[0];
        } else {
          push @roots, $node;
        }
      }

      push @children, grep { not exists($mapping->{$_->{id}}) } $node->children;
    }

    #if (scalar(@roots) > 1) {
    #  my $members = 0;
    #  my %parents = ();
    #  foreach my $r (@roots) {
    #    $members++ if $r->{is_member};
    #    $parents{$r->parent->{id}} = 1;
    #  }

    #  if ($members > 0 and $members != scalar(@roots)) {
    #    print STDERR "WARNING: is_member mismatch in MWE ".$mwe->[0]->{id}."\n";
    #  }
    #  if (scalar keys %parents > 1) {
    #    print STDERR "WARNING: multiple parents of MWE ".$mwe->[0]->{id}."\n";
    #  }
    #}

    { use List::MoreUtils;
    if (uniq(@roots) > 1) { # in case of #Forn and many FPHR, all @roots are same
      # Find root that is the most upper one, closest to the tree-root
      my $min_node;
      my $min_depth = 999;
      foreach my $r (@roots) {
        my $_r = $r->parent;
        my $depth = 0;
        while ($_r) {
          $depth++;
          $_r = $_r->parent;
        }
        if ($depth < $min_depth) {
          $min_depth = $depth;
          $min_node = $r;
        }
      }
      $root = $min_node;
    } else {
      $root = $roots[0];
    }}

    $mwe->[0]->{functor} = $root->{functor};
    $mwe->[0]->{is_member} = 1 if $root->{is_member};
    $mwe->[0]->{is_parenthesis} = 1 if $root->{is_parenthesis};
    $mwe->[0]->{deepord} = $root->{deepord} - 1;
    $mwe->[0]->{'mwe_root'} = $root;

    my $parent = $root->parent;
    if (exists($mapping->{$parent->{id}})) {
      CutPaste($mwe->[0], $mapping->{$parent->{id}});
    } else {
      CutPaste($mwe->[0], $parent);
    }

    foreach my $node (@children) {
      $node->{'std_parent'} = $node->parent;
      $node->{'mwe_parent'} = $mwe->[0];
    }
  }

  $tree->{hide} = 0;
  foreach my $node ($tree->descendants) {
    if (exists $node->{'mwe_root'}) {
      $node->{hide} = $PDT_C_T::mwe_folding ? 0 : 1;
    } elsif (exists $mapping->{$node->{id}}) {
      $node->{hide} = $PDT_C_T::mwe_folding ? 1 : 0;
    } else {
      $node->{hide} = 0;
    }

    foreach my $attr ('compl.rf', 'coref_gram.rf', 'coref_text.rf') {
      foreach my $ref (ListV($node->{$attr})) {
        my $ref_node = GetNodeByID($ref);
        my ($mwe_begin, $mwe_end); 

        if (exists $mapping->{$node->{id}}) {
          $mwe_begin = $mapping->{$node->{id}};
        } else {
          $mwe_begin = $node; 
        }

        if (exists $mapping->{$ref_node->{id}}) {
          $mwe_end = $mapping->{$ref_node->{id}}->{id};
        } else {
          $mwe_end = $ref_node->{id};
        }

        # Happens when both the beginning and the end of the arrow are within the same MWE
        next if $mwe_begin->{id} eq $mwe_end;
        
        if ($mwe_begin != $node) {
          AddToListUniq($mwe_begin, $attr, $mwe_end);
        } elsif ($mwe_end ne $ref_node->{id}) {
          $node->{$attr} = ListV(ListSubtract($node->{$attr}, List($ref_node->{id})));
          push @{$node->{'mwe_refs'}}, [ $attr, $ref_node->{id}, $mwe_end ];
        }
      }
    }
  }

  FileUserData('mwe', $mapping);
  normalize_ordering($tree);
  $tree->{'_mwe_ok'} = 1;
  rehang_mwes($tree);
}


# We need to overload this because of the folded MWE nodes
sub IsCoord {
  my $node=$_[0] || $this;
  return 0 unless $node;
  return 0 if exists $node->{'mwe_root'};
  return 0 if !defined($node->{functor});
  return $node->{functor} =~ /^(?:ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS)$/;
}

sub prepare_styles {
  my $tree = shift;
  my $coord_decor = '#{Line-decoration:shape=oval;coords=-20,-20,20,20;outline='.CustomColor('line_coord').';width=1;dash=5,5 }';
  $coord_decor .= '#{Line-arrow:&}#{Line-arrowshape:&}#{Line-tag:&}#{Line-smooth:&}';
  $coord_decor .= '#{Oval-fill:'.CustomColor('tnode_coord').'}';

  # For coordination roots
  my $k1 = '20 / sqrt((xp-xn)**2 + (yp-yn)**2)';
  my $x1 = 'xn-(xn-xp)*'.$k1;
  my $y1 = 'yn-(yn-yp)*'.$k1;
  # For coordination members
  my $k2 = '(1 - 20 / sqrt((xp-xn)**2 + (yp-yn)**2))';
  my $x2 = 'xn-(xn-xp)*'.$k2;
  my $y2 = 'yn-(yn-yp)*'.$k2;

  foreach my $node ($tree->descendants) {
    my ($style, $coords, $width, $color, $dash) = ('', '', '', '');
    my $nondep = ($node->{functor} =~ m/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/ or $node->parent == $tree);

    if (IsCoord($node)) {
      $style .= $coord_decor;
      $coords = "n,n,n,n&$x1,$y1";
      $width = '0&';
      $color = 'white&';
      $dash = '&';
    } else {
      $coords = 'n,n';
    }
    if (IsCoord($node->parent)) {
      $coords .= ",$x2,$y2";
    } else {
      $coords .= ',p,p';
    }

    if (IsCoord($node->parent) and not $nondep) {
      $color .= $node->{is_member} ? CustomColor('line_coord') : CustomColor('line_comm');
    } elsif (IsCoord($node)) {
      $color .= $nondep ? CustomColor('line_normal') : CustomColor('line_coord');
    } elsif ($node->{is_member}) {
      $color .= CustomColor('error');
    }

    $width .= '1' if $node->{is_member} or $nondep or (IsCoord($node) and not (IsCoord($node->parent) and not $node->{is_member}));
    $dash .= '2,4' if $nondep;

    $style .= "#{Line-coords:$coords}";
    $style .= "#{Line-fill:$color}" if $color;
    $style .= "#{Line-width:$width}" if $width;
    $style .= "#{Line-dash:$dash}" if $dash;

    $node->{style} = $style;
  }

  $tree->{style} = '';
  $tree->{'_styles_ok'} = 1;
}

sub root_style_hook {
  # for each tree, set the %cortype only once
  my %cortype = (
    grammatical => ['coref_gram.rf', 1, 0],
    textual => [ 'coref_text' , get_display_coref_text() ne 2, 0 ],
    compl => [ 'compl.rf', 1, 0 ],
    bridging => [ 'bridging', get_display_bridging() ne 2, 0 ],
    discourse => [ 'discourse', get_display_discourse() ne 2, 0 ],
  );
  FileUserData('node_style_hook__refha_cortype',\%cortype);
  PML_T::root_style_hook(@_);
}

sub node_style_hook {
  my ($node,$styles)=@_;

  my $node_orig = $node;
  my $node_id = $node->attr('id');
  my $mwe_mapping = FileUserData('mwe');

  # Check if the start node is hidden inside a mwe
  if ($PDT_C_T::mwe_folding && exists $mwe_mapping->{$node_id}) {
    $node = $mwe_mapping->{$node_id};
    # print STDERR "Moving start node " . $node_orig->attr('t_lemma') . " to " . $node->attr('id') . "\n";
  }

  my %arrows;
  my $refha_cortype = FileUserData('node_style_hook__refha_cortype'); # it is set in root_style_hook

  my %target_ids_counts; # for keeping track of how many arrows go to the same target (in order to make them all visible)
  for my $type (keys %$refha_cortype) {
    my ($attr,$show,$source)=@{ $$refha_cortype{$type} };
    if ($show) {
      my $map_target = ($attr=~/\.rf$/) ? 0 : 1;
      my @arrows_structures;
      @arrows_structures = ListV($node_orig->{$attr});

      my @arrs = map {
        my $arrow = $_;

        # if ($node_orig->{'hide'}) {
        #   print STDERR "A hidden node: " . $node_orig->attr('t_lemma') . "\n";  
        # }

        my $ref_id = $map_target ? (ref($arrow) && $arrow->{'target_node.rf'}) : $arrow;
        my $ref_id_orig = $ref_id;

        if (!defined($ref_id)) {
          $ref_id = 0; # let's get rid of warnings when the target_node.rf is not defined (like at the first member of the discourse 'list')
        }

        my $target = PML::GetNodeByID($ref_id);
        my $target_orig = $target;
        # Check if the target node is hidden inside a mwe
        if ($PDT_C_T::mwe_folding && exists $mwe_mapping->{$ref_id}) {
          $target = $mwe_mapping->{$ref_id};
          $ref_id = $target->attr('id');
          # print STDERR "Moving target to $ref_id\n";
        }

        my $ret = {
          -target_id => $ref_id,
          -cortype => $type,
        };
        if ($node ne $node_orig) {
          $ret->{-dash} = ($ref_id_orig ne $ref_id) ? '.' : '10,6,2,2';
        } elsif ($ref_id_orig ne $ref_id) {
          $ret->{-dash} = '10,2,2,6';
        }

        # add a hint to the discourse arrow:
        if ($type eq 'discourse') {
          my $arrow_type = $arrow->{'type'} || '';
          my $discourse_type = $arrow->{'discourse_type'} || '';
          if (is_negated($arrow)) {
            $discourse_type = '!' . $discourse_type;
          }
          my $sense_PDTB3 = $arrow->{'sense_PDTB3'} || '';
          my $sense_PDTB3_manual = $arrow->{'sense_PDTB3_manual'} || '';
          $sense_PDTB3 = $sense_PDTB3_manual if ($sense_PDTB3_manual);
          my $sense1B_PDTB3 = $arrow->{'sense1B_PDTB3'} || '';
          my $sense1B_PDTB3_manual = $arrow->{'sense1B_PDTB3_manual'} || '';
          $sense1B_PDTB3 = $sense1B_PDTB3_manual if ($sense1B_PDTB3_manual);
          my $start_range = $arrow->{'start_range'};
          $start_range = '-' if (!defined($start_range));
          if ($start_range eq 'group') {
            my $start_group_id = $arrow->{'start_group_id'} || '?';
            $start_range .= ' ' . $start_group_id;
          }
          my $target_range = $arrow->{'target_range'};
          $target_range = '-' if (!defined($target_range));
          if ($target_range eq 'group') {
            my $target_group_id = $arrow->{'target_group_id'} || '?';
            $target_range .= ' ' . $target_group_id;
          }
          my $hint = 'connective' . (is_secondary($arrow) ? '_sec: ' : ': ') . get_surface_connective($arrow);
          my $ext_conn = get_surface_connective_ext($arrow);
          if ($ext_conn) {
            $hint .= "\next. connective: $ext_conn";
          }
          $hint .= "\ntype: " . $arrow_type;
          if ($arrow_type eq 'discourse') {
            $hint .= "\ndiscourse type: " . $discourse_type;
            $hint .= "\nPDTB3 sense: " . $sense_PDTB3 if $sense_PDTB3;
            $hint .= "\nPDTB3 sense1B: " . $sense1B_PDTB3 if $sense1B_PDTB3;
          }
          $hint .= "\nstart range: " . $start_range
                  . "\ntarget range: " . $target_range;
          if ($node_orig ne $node) {
            $hint .= "\nstart: " . $node_orig->attr('t_lemma');
          }
          if ($ref_id_orig ne $ref_id) {
            my $target_t_lemma = $target_orig ? $target_orig->attr('t_lemma') : 'no_target';
            $hint .= "\ntarget: $target_t_lemma";
          }
          $ret->{'-hint'} = $hint;
          $ret->{'-width'} = $arrow_type eq 'discourse' ? 3 : 1;
        }
        # add a hint to the coref_text arrow:
        elsif ($type eq 'textual') {
          my $inf_type = $arrow->{'type'} || '';
          my $hint = "type: " . $inf_type;
          if ($node_orig ne $node) {
            $hint .= "\nstart: " . $node_orig->attr('t_lemma');
          }
          if ($ref_id_orig ne $ref_id) {
            my $target_t_lemma = $target_orig ? $target_orig->attr('t_lemma') : 'no_target';
            $hint .= "\ntarget: $target_t_lemma";
          }
          $ret->{'-hint'} = $hint;
        }
        # add a hint to the bridging arrow:
        elsif ($type eq 'bridging') {
          my $inf_type = $arrow->{'type'} || '';
          my $hint = 'type: ' . $inf_type;
          if ($node_orig ne $node) {
            $hint .= "\nstart: " . $node_orig->attr('t_lemma');
          }
          if ($ref_id_orig ne $ref_id) {
            my $target_t_lemma = $target_orig ? $target_orig->attr('t_lemma') : 'no_target';
            $hint .= "\ntarget: $target_t_lemma";
          }
          $ret->{'-hint'} = $hint;
        }

        # check if there have been previous arrows going to the same target
        my $target_id_count = $target_ids_counts{$ref_id};
        if (!defined($target_id_count)) {
          $target_id_count = 0;
        }
        $target_id_count ++;
        $target_ids_counts{$ref_id} = $target_id_count;
        if ($target_id_count > 1) { # more than one arrow going to the same target
          $ret->{'-frac'} = ($target_id_count - 1.0) * 0.1 + 0.12;
        }
        $ret
      } grep { defined and length } @arrows_structures;

      push @{$arrows{$type}}, @arrs;
    }
  }

  my @arrow_types = sort keys %arrows;
  my $refar_node_ids = [ map { map $_->{'-target_id'}, @{$arrows{$_}} } @arrow_types ];
  my $refar_coreftypes = [ map { @{$arrows{$_}} } @arrow_types ];

  # if ($node ne $node_orig) {
  #   print STDERR "Calling DrawCorefArrows with a different start node:\n";
  #   print STDERR "  " . $node->attr('id') . "\n";
  #   print STDERR "Node ids:\n";
  #   foreach my $id (@$refar_node_ids) {
  #     print STDERR "  $id\n";
  #   }
  # }
  
  PML_T::DrawCorefArrows($node, $styles, undef, $refar_node_ids, $refar_coreftypes, undef, undef); # $refha_style_opts);
  # DrawCorefArrows($node, $styles, $refar_node_ids, $refar_coreftypes); # needs fixes before it could be used

  return 1;
} # node_style_hook

=item DrawCorefArrows() ... a copy from PML_T

Called from C<node_style_hook>. Draws coreference arrows using
following properties: textual arrows in CustomColor C<arrow_textual>,
grammatical in <arrow_grammatical> (and dashed in Full stylesheet),
complement arrow in C<arrow_compl> (and dot-dashed in Full
stylesheet), segment arrow in C<arrow_segm> and exophora arrow in
C<arrow_exoph>.

sub DrawCorefArrows {
  my ($node,$styles,$line,$corefs,$cortypes,$reserved,$style_opts)=@_;

  # corefs is an array-ref of node IDs
  # coreftypes is an array-ref of cortypes strings or
  # of hashes { -cortype => 'cortype', ...edge_options... }
  # specifying a cortype and custom edge drawing options passed to
  # DrawArrows from <contrib/support/arrows.inc>

  my ($rotate_prv_snt,$rotate_nxt_snt,$rotate_dfr_doc)=(0,0,0);
  my @edges;
  $style_opts ||= {};
  my %common = (
    -arrow => 'last',
    -smooth => 1,
    -arrowshape => '16,18,3',
    -width => 1,
    -dash => '',
    %{$style_opts->{'*'}||{}},
  );
  foreach my $coref (@$corefs) {
    my $cortype=shift @$cortypes;
    my $edge_style;
    if (ref $cortype) {
      $edge_style = $cortype;
      $cortype = delete $edge_style->{-cortype};
    }
    my($refed,$treeNo)=SearchForNodeById($coref);
    print STDERR "node_id = " . $node->attr('id') . ", target treeNo: $treeNo\n";
    my %edge = (-tag => $cortype,
                %{$style_opts->{$cortype}||{}},
               );
    if ($refed) {
      my $orientation=
        exists($PML_T::displayed_nodes{$refed}) ? 0 : $treeNo-CurrentTreeNumber()-1;
      $PML_T::coreflemmas_hash{$node->{id}}.=' '.$refed->{t_lemma} if $orientation;
      if ($orientation == 0) {
        $edge{-target} = $refed;
        $edge{-fill}=CustomColor('arrow_'.$cortype);
        $edge{-dash}=GetPatternsByPrefix('full')?($cortype eq'compl'?'2,3,5,3':$cortype eq'grammatical'?'5,3':''):'';
      } elsif ($orientation<0) {
        print STDERR "ref-arrows: Preceding sentence\n"if $main::macroDebug;
        $edge{-fill}=CustomColor('arrow_'.$cortype);
        $edge{-deltax}=-30;
        $edge{-deltay}=10*($rotate_prv_snt++);
      }else{ #right
        print STDERR "ref-arrows: Following sentence\n" if $main::macroDebug;
        $edge{-fill}=CustomColor('arrow_'.$cortype);
        $edge{-deltax}=+30;
        $edge{-deltay}=10*($rotate_nxt_snt++);
      }
    } else {
      print STDERR "ref-arrows: Not found!\n" if $main::macroDebug;
      $edge{-fill}=CustomColor('error');
      $edge{-deltax}=10*($rotate_dfr_doc++);
      $edge{-deltay}=-25;
    }
    push @edges,{%edge, %{$edge_style||{}}};
  }
  if ($node->{coref_special} and $node->{coref_special} eq 'segm') { # pointer to an unspecified segment of preceeding sentences
    print STDERR "ref-arrows: Segment - unaimed arrow\n" if $main::macroDebug; 
    push @edges, {
      -fill   => CustomColor('arrow_segment'),
      -deltax => -25,
      -deltay => 10*($rotate_prv_snt++),
      -tag => 'segm',
      %{$style_opts->{segm}||{}},
    };
  }
  if ($node->{coref_special} and $node->{coref_special} eq 'exoph') {
    print STDERR "ref-arrows: Exophora\n" if $main::macroDebug;
    push @edges, {
      -fill   => CustomColor('arrow_exoph'),
      -deltax => 10*($rotate_dfr_doc++),
      -deltay => -25,
      -tag => 'exoph',
      %{$style_opts->{exoph}||{}},
    };
  }
  # print STDERR "Going to call DrawArrows...\n";
  DrawArrows($node,$styles,\@edges,\%common);
}

=cut

=item node_style_hook from PDT 2.5

# Overloading methods from PML_T because of new visualization of paratactic structures.
# Arrows have to end before the node on the border of the decorative circle around the
# coordination root.
sub node_style_hook {
  my ($node,$styles)=@_;
  if ($node->{'coref_text.rf'} or $node->{'coref_gram.rf'} or $node->{'compl.rf'}) {
    my @gram = grep {$_ ne "" } ListV($node->{'coref_gram.rf'});
    my @text = grep {$_ ne "" } ListV($node->{'coref_text.rf'});
    my @compl = grep {$_ ne "" } ListV($node->{'compl.rf'});
    DrawCorefArrows($node,$styles,
      [@gram,@text,@compl],
      [ (map 'grammatical',@gram),
        (map 'textual',@text),
        (map 'compl',@compl)
      ],
    );
  }
  return 1;
}

=cut

=item DrawCorefArrows from PDT 2.5 (slightly but not sufficiently modified for PDT 3.0) 

sub DrawCorefArrows {
  my ($node, $styles, $target_ids, $arrow_types) = @_;
  my (@coords, @colors, @dash, @tags);
  my ($rotate_prv_snt, $rotate_nxt_snt, $rotate_dfr_doc) = (0, 0, 0);
  my %line = GetStyles($styles, 'Line');

  foreach my $target_id (@$target_ids) {
    my $arrow_type = shift @$arrow_types;
    my $edge_style;
    if (ref $arrow_type) {
      $edge_style = $arrow_type;
      $arrow_type = delete $edge_style->{-cortype};
    }

    $arrow_type = 'arrow_' . $arrow_type;

    my $target_node = GetNodeByID($target_id);
    next if $target_node->{hide};

    if ($target_node) {
      if (not exists $root_index{$target_node->root->{id}}) {
        my @trees = GetTrees();
        for (my $i = 0; $i < scalar(@trees); $i++) {
          $root_index{$trees[$i]->{id}} = $i;
        }
      }

      my $pos = $root_index{$target_node->root->{id}} - CurrentTreeNumber();
      if ($pos != 0) {
        my $lemma = $target_node->{'mwe_root'} ? $target_node->{label} : $target_node->{t_lemma};
        $PML_T::coreflemmas_hash{$node->{id}} .= ' '.$lemma;
      }
        
      if ($pos == 0) { # same sentence
        my $T = "[?\$node->{id} eq '$target_id'?]";
        my $X = "(x$T-xn)";
        my $Y = "(y$T-yn)";
        my $D = "sqrt($X**2+$Y**2)";
        my $BX = 'n';
        my $BY = 'n';
        my $MX = "((x$T+xn)/2 - $Y*(25/$D+0.12))";
        my $MY = "((y$T+yn)/2 + $X*(25/$D+0.12))";
        my $EX = "x$T";
        my $EY = "y$T";
        my $K1 = "20 / sqrt(($MX-xn)**2 + ($MY-yn)**2)";
        my $K2 = "20 / sqrt((x$T-$MX)**2 + (y$T-$MY)**2)";
        
        if (IsCoord($node)) {
          $BX = "xn-(xn-$MX)*$K1";
          $BY = "yn-(yn-$MY)*$K1";
        }
        if (IsCoord($target_node)) {
          $EX = "x$T+($MX-x$T)*$K2";
          $EY = "y$T+($MY-y$T)*$K2";
        }
        
        push @coords, "$BX,$BY,$MX,$MY,$EX,$EY";
      } else {
        if ($pos < 0) {
          push @coords, "n,n,n-30,n+$rotate_prv_snt";
          $rotate_prv_snt += 10;
        } else {
          push @coords, "n,n,n+30,n+$rotate_nxt_snt";
          $rotate_nxt_snt += 10;
        }
      }

      push @colors, CustomColor($arrow_type);
    } else {
      push @coords, "n,n,n+$rotate_dfr_doc,n-25";
      $rotate_dfr_doc += 10;
      push @colors, CustomColor('error');
    }

    push @tags, $arrow_type;
  }

  if (@coords) {
    TredMacro::AddStyle(
      $styles, 'Line',
      -coords => ( $line{-coords} || '' ) .'&'. join( '&', @coords ),
      -arrow      => ( $line{-arrow} || '' ) . ( '&last' x @coords ),
      -arrowshape => ( $line{-arrowshape} || '' ) . ( '&16,18,3' x @coords ),
      -dash => ( $line{-dash} || '' ) .'&'. join( '&', @dash ),
      -width => ( $line{-width} || '' ) . ( '&1' x @coords ),
      -fill => ( $line{-fill} || '' ) .'&'. join( '&', @colors ),
      -tag  => ( $line{-tag}  || '' ) .'&'. join( '&', @tags ),
      -smooth => ( $line{-smooth} || '' ) . ( '&1' x @coords )
    );
  }
  return;
}

=cut

=item

  Given a discourse arrow structure (a member of the list obtained e.g. by ListV($node->{'discourse'})), it returns the value of attribute is_negated.

=cut

sub is_negated {
  my ($arrow_structure) = @_;
  my $is_negated = $arrow_structure->{'is_negated'};
  return $is_negated;
}

=item

  Given a discourse arrow structure (a member of the list obtained e.g. by ListV($node->{'discourse'})), it returns the value of attribute is_secondary.

=cut

sub is_secondary {
  my ($arrow_structure) = @_;
  my $is_secondary = $arrow_structure->{'is_secondary'};
  return $is_secondary;
}

=item

  Returns 1 if the node is a list entry (a discourse arrow of type 'list' starts there); otherwise returns 0

=cut

sub is_list_entry {
  my ($node) = @_;
  my @discourse_arrows = ListV($node->attr('discourse'));
  foreach my $discourse_arrow (@discourse_arrows) {
    my $type = $discourse_arrow->{'type'};
    if ($type && $type eq 'list') {
      return 1;
    }
  }
  return 0;
}


=item

  Given a discourse arrow structure (a member of the list obtained e.g. by ListV($node->{'discourse'})), it returns the surface representation
  of the connectors attached to the arrow.

=cut

sub get_surface_connective {
  my ($arrow_structure) = @_;

  my @connectors_t_ids = ListV($arrow_structure->{'t-connectors.rf'});
  my @connectors_a_ids = ListV($arrow_structure->{'a-connectors.rf'});
  if (!scalar(@connectors_t_ids) and !scalar(@connectors_a_ids)) {
    return '';
  }
  return get_surface_connective_or_extended_connective(\@connectors_t_ids, \@connectors_a_ids);
}

=item

  Given a discourse arrow structure (a member of the list obtained e.g. by ListV($node->{'discourse'})), it returns the surface representation
  of the extended connectors attached to the arrow.

=cut

sub get_surface_connective_ext {
  my ($arrow_structure) = @_;

  my @connectors_t_ids = ListV($arrow_structure->{'t-connectors_ext.rf'});
  my @connectors_a_ids = ListV($arrow_structure->{'a-connectors_ext.rf'});
  if (!scalar(@connectors_t_ids) and !scalar(@connectors_a_ids)) {
    return '';
  }
  return get_surface_connective_or_extended_connective(\@connectors_t_ids, \@connectors_a_ids);
}

sub get_surface_connective_or_extended_connective {
  my ($pa_connectors_t_ids, $pa_connectors_a_ids) = @_;
  
  my @connectors_t_ids = @$pa_connectors_t_ids;
  my @connectors_a_ids = @$pa_connectors_a_ids;

  my @connectors_t_nodes = map {PML::GetNodeByID($_)} @connectors_t_ids; # find tectogrammatical nodes given the references
  my @connectors_a_nodes = map {PML_T::GetANodeByID($_)} @connectors_a_ids; # find analytical nodes given the references

  my %h_a_surface_connectors;

  my $add_negation = 0;

  foreach my $t_node (@connectors_t_nodes) {
    my @a_nodes = PML_T::GetANodes($t_node);
    if (!@a_nodes) { # no analytical counterparts
      if ($t_node->attr('t_lemma') eq '#Neg') {
        $add_negation = 1;
      }
      else {
        my $t_parent = $t_node->parent;
        if ($t_parent) {
          @a_nodes = PML_T::GetANodes($t_parent);
        } # if no parent - give up
      }
    }
    if (@a_nodes) {
      push(@connectors_a_nodes, @a_nodes);
    }
  }

  foreach my $a_node (@connectors_a_nodes) {
    my $ord = $a_node->attr('ord');
    my $root_id = $a_node->root->attr('id');
    my $tree_fake_number = 0;
    if ($root_id =~ /-p(\d+)s(\d+)([A-Z]?)/) {
      $tree_fake_number = $1 * 1000000 + $2 * 1000;
      if ($3) {
        $tree_fake_number += ord($3);
      }
    }
    my $pa_a_surface_connector = $h_a_surface_connectors{"$tree_fake_number"};
    if (!defined($pa_a_surface_connector)) {
      $h_a_surface_connectors{"$tree_fake_number"} = [];
      $pa_a_surface_connector = $h_a_surface_connectors{"$tree_fake_number"};
    }
    if (defined($$pa_a_surface_connector[$ord])) {
      $$pa_a_surface_connector[$ord] = $$pa_a_surface_connector[$ord] . ' ' . $a_node->attr('m/form');
    }
    else {
      $$pa_a_surface_connector[$ord] = $a_node->attr('m/form');
    }
  }

  my $surface_connective = "";
  foreach my $tree_fake_number (sort keys %h_a_surface_connectors) { # for each tree containing a part of the connective
    my $pa_a_surface_connector = $h_a_surface_connectors{"$tree_fake_number"};
    foreach my $form (@$pa_a_surface_connector) {
      if (defined($form)) {
        if (length($surface_connective)) {
          $surface_connective .= ' ';
        }
        $surface_connective .= $form;
      }
    }
  }

  if ($add_negation) {
    $surface_connective = '#Neg ' . $surface_connective;
  }
  return $surface_connective;
}


sub get_document_genre {
  my $genre = $grp->{FSFile}->metaData('pml_root')->{meta}{genre};
  return $genre;
}

# a function for toggling displaying of multiword expressions
# 0 means unfolded with highlighted groups of nodes forming the expressions
# 1 means folded
# 2 means unfolded without highlighting the node groups

sub toggle_mwe_folding {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::mwe_folding = (($PDT_C_T::mwe_folding or 0) + 1) % 3;
  
  # print STDERR $PDT_C_T::mwe_folding . "\n";
  my $mwe_mapping = FileUserData('mwe');

  my $new_this = $this;
  if (($PDT_C_T::mwe_folding eq 1) and exists $mwe_mapping->{$this->{id}}) {
    $new_this = $mwe_mapping->{$this->{id}};
  } elsif ((($PDT_C_T::mwe_folding eq 0) or ($PDT_C_T::mwe_folding eq 2)) and exists $this->{'mwe_root'}) {
    $new_this = $this->{'mwe_root'};
  }
  $this = $new_this;

  if ($PDT_C_T::mwe_folding ne 0) {
    foreach my $tree (GetTrees()) {
      rehang_mwes($tree);
    }
  }

  ChangingFile(0);
}


# before a file is saved, all newly introduced nodes representing mwes need to be removed from the trees
sub file_save_hook {
  # print STDERR "file_save_hook: going to remove artificial mwe nodes.\n";
  remove_mwe_nodes();
}

# before the context is switched, all newly introduced nodes representing mwes need to be removed from the trees
sub pre_switch_context_hook {
  # print STDERR "pre_switch_context_hook: going to remove artificial mwe nodes.\n";
  remove_mwe_nodes();
}

# Removes all artificial mwe nodes.
sub remove_mwe_nodes {
  foreach my $tree (GetTrees()) {
    if ($tree->{'_mwe_ok'}) {
      foreach my $node (GetNodes($tree)) {
	if ($node->{'std_parent'} && $node->{'mwe_parent'}) {
	  CutPaste($node, $node->{'std_parent'});
	}
      }
      my $remains = 1;
      while ($remains) { # some mwe nodes remain to be removed (in the previous run there was a mwe node that was not a leaf and therefore could not be deleted)
        $remains = 0;
        foreach my $mwe (ListV($tree->{mwes})) {
          my $id = $mwe->{id};
          my $node = GetNodeByID($id);
          if ($node) { # the node has not yet be deleted (in a previous run)
            # print STDERR "Deleting leaf node $id.\n";
            if ($node->children) {
              # print STDERR " - not a leaf, could not be deleted! Will try in the next run.\n";
              $remains = 1;
            }
            else {
              DeleteLeafNode($node);
              # print STDERR "Deleting from hash $id.\n";
              DeleteFromNodeHash($id);
            }
          }
        }
      }
    }
    delete($tree->{'_mwe_ok'});
  }
}


sub rehang_mwes {
  my $tree = shift;
  return unless $tree->{'_mwe_ok'};
  my $mapping = FileUserData('mwe');

  $tree->{hide} = 0;
  foreach my $node ($tree->descendants) {
    if (exists($node->{'mwe_parent'})) {
      if ($PDT_C_T::mwe_folding eq 1) {
        CutPaste($node, $node->{'mwe_parent'});
      } else {
        CutPaste($node, $node->{'std_parent'});
      }
    }

    if (exists $node->{'mwe_refs'}) {
      foreach my $ref (@{$node->{'mwe_refs'}}) {
        $node->{$ref->[0]} = ListV(ListSubtract($node->{$ref->[0]}, List($ref->[1], $ref->[2])));
        AddToList($node, $ref->[0], $PDT_C_T::mwe_folding ? $ref->[2] : $ref->[1]);
      }
    }

    if (exists $mapping->{$node->{id}}) {
      $node->{hide} = $PDT_C_T::mwe_folding eq 1 ? 1 : 0;
    } elsif (exists $node->{'mwe_root'}) {
      $node->{hide} = $PDT_C_T::mwe_folding eq 1 ? 0 : 1;
    } else {
      $node->{hide} = 0;
    }
  }
}


# a set of functions to toggle displaying non-dependency relations (discourse, coref_text, bridging)
# three states: 0 - display only the arrows, 1 - display arrows and additional info, 2 - do not display

sub toggle_displaying_discourse {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_discourse = (($PDT_C_T::toggle_displaying_discourse or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_discourse

sub get_display_discourse {
  return $PDT_C_T::toggle_displaying_discourse || 0;
}

sub toggle_displaying_coref_text {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_coref_text = (($PDT_C_T::toggle_displaying_coref_text or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_coref_text

sub get_display_coref_text { 
  return $PDT_C_T::toggle_displaying_coref_text || 0;
}

sub toggle_displaying_bridging {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_bridging = (($PDT_C_T::toggle_displaying_bridging or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_bridging

sub get_display_bridging { 
  return $PDT_C_T::toggle_displaying_bridging || 0;
}


# functions to toggle displaying t_lemma_trans
# three states: 0 - display below t_lemmas, 1 - display next to t_lemma, 2 - do not display

sub toggle_displaying_t_lemma_trans {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_t_lemma_trans = (($PDT_C_T::toggle_displaying_t_lemma_trans or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_t_lemma_trans

sub get_display_t_lemma_trans {
  return $PDT_C_T::toggle_displaying_t_lemma_trans || 0;
}


# functions to toggle displaying a-nodes or grammatemes (or nothing)
# three states: 0 - grammatemes, 1 - a-nodes, 2 - nothing

sub toggle_displaying_a_nodes_grams {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_a_nodes_grams = (($PDT_C_T::toggle_displaying_a_nodes_grams or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_a_nodes_grams

sub get_display_a_nodes_grams {
  return $PDT_C_T::toggle_displaying_a_nodes_grams || 0;
}


# functions to toggle displaying the t-root id
# two states: 0 - display root id, 1 - do not display

sub toggle_displaying_t_root_id {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_t_root_id = (($PDT_C_T::toggle_displaying_t_root_id or 0) + 1) % 2;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_t_root_id

sub get_display_t_root_id {
  return $PDT_C_T::toggle_displaying_t_root_id || 0;
}


# functions to toggle displaying tfa
# three states: 0 - display normally (small colored nodes, nothing else), 1 - large nodes, 2 - large nodes and the tfa value next to the functor

sub toggle_displaying_tfa {
  return unless SchemaName() eq 'tdata';
  $PDT_C_T::toggle_displaying_tfa = (($PDT_C_T::toggle_displaying_tfa or 0) + 1) % 3;
  ChangingFile(0); # otherwise the user is prompted to save "changed" file while listing among PML-TQ results
} # toggle_displaying_tfa

sub get_display_tfa {
  return $PDT_C_T::toggle_displaying_tfa || 0;
}

# Returns 1 if the node is tfa-relevant, i.e. it should have tfa value assigned; otherwise returns 0
sub is_tfa_relevant {
  my ($node) = @_;
  if ($node eq $root) {
    return 0;
  }
  my $nodetype = $node->attr('nodetype');
  if (defined($nodetype) and ($nodetype eq 'coap' or $nodetype eq 'fphr')) {
    return 0;
  }
  my $functor = $node->attr('functor');
  if (defined($functor) and ($functor eq 'CM' or $functor eq 'FPHR')) {
    return 0;
  }
  return 1;
} # is_tfa_relevant


=item compare_target_nodes_positions_deepord

  Compares positions according to the tree number and deepord of the target nodes of the given links.

=cut

# used in the stylesheets
sub compare_target_nodes_positions_deepord ($$) {
  my ($link1, $link2) = @_;
  my $id1 = $link1->{'target_node.rf'};
  my $id2 = $link2->{'target_node.rf'};
  if (!$id1) { # possible when there is no target_node.rf - like at the first member of the discourse 'list'
    return 1;
  }
  if (!$id2) { # possible when there is no target_node.rf - like at the first member of the discourse 'list'
    return -1;
  }
  my $node1 = PML::GetNodeByID($id1);
  my $node2 = PML::GetNodeByID($id2);
  return compare_nodes_positions_deepord($node1, $node2);
} # compare_target_nodes_positions_deepord


=item compare_nodes_positions_deepord

  Compares nodes positions according to the tree number and deepord

=cut

sub compare_nodes_positions_deepord ($$) {
  my ($node1, $node2) = @_;
  my ($a_file_name, $a_tree_index, $a_file) = LocateNode($node1);
  my ($b_file_name, $b_tree_index, $b_file) = LocateNode($node2);
  if ($a_tree_index < $b_tree_index) {
    return -1;
  }
  if ($a_tree_index > $b_tree_index) {
    return 1;
  }
  # the nodes are from the same tree, let us compare deepord
  return $node1->attr('deepord') <=> $node2->attr('deepord');
} # compare_nodes_positions_deepord


1;
