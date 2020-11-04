# -*- cperl -*-

use strict;
BEGIN {
  import PML_M;
}

sub detect {
  return (PML::SchemaDescription() =~ m/^PDT-C/ and PML::SchemaName() eq 'mdata') ? 1 : 0;
}

sub allow_switch_context_hook {
  return 'stop' unless detect();
}

sub switch_context_hook {
  my $cur_stylesheet = GetCurrentStylesheet();
  if ($cur_stylesheet ne 'PDT_C_M') {
    SetCurrentStylesheet('PDT_C_M');
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
  
  my $node = $tree->following;
  while ($node) {
    my $token = $node->attr('w/token');
    my $form = $node->attr('form');
    
    if ($form ne $token) {
      push @out, (['['.$token.']', $node, '-over=>1', '-foreground=>'.CustomColor('spell')]);
    }
    
    push @out, ([$form, $node]);

    unless($node->attr('w/[-1]/no_space_after')) {
      push @out, ([" ","space"]);
    }

    $node = $node->following;
  }
  
  return \@out;
}

1;

