# -*- cperl -*-

{
  my @CustomColors = do {
    no warnings 'qw';
    qw/ mwe_node RoyalBlue1
        line_normal #555555
        line_coord #bbbbbb
        line_comm aquamarine4
        tnode #bbbbbb
        tnode_coord LightCyan1/};

  while(@CustomColors) {
    my $key = shift @CustomColors;
    my $val = shift @CustomColors;
    TredMacro::CustomColor($key,$val);
  }
}

