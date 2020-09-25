#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

use File::Basename;

use Ufal::MorphoDiTa;

@ARGV >= 1 or die "Usage: $0 dictionary_file [resensing_file]\n";

print STDERR "Loading dictionary: ";
my $dictionary = Ufal::MorphoDiTa::Morpho::load($ARGV[0]);
$dictionary or die "Cannot load dictionary from file '$ARGV[0]'\n";
print STDERR "done\n";
shift @ARGV;

my %resensing;
if (@ARGV) {
  print STDERR "Loading resensing log: ";
  open (my $resensing_file, "<", $ARGV[0]) or die "Cannot open file $ARGV[0]";
  while (<$resensing_file>) {
    /Resense (\S+) .*to (\S+)/ or die "Cannot parse resense line $_";
    $resensing{$1} = $2;
    die "Recursive resensing for $2" if exists $resensing{$2};
  }
  print STDERR "done\n";
  shift @ARGV;
}

my $lemmas = Ufal::MorphoDiTa::TaggedLemmas->new();

my $group_script = "python3 " . dirname($0) . "/consistency_vertical_grouper.py";
open (my $f_unique, "|-", "$group_script unique.txt") or die;
open (my $f_multiple_uniquetag, "|-", "$group_script multiple_uniquetag.txt") or die;
open (my $f_multiple_nonuniquetag, "|-", "$group_script multiple_non-uniquetag.txt") or die;
open (my $f_no_analysis, "|-", "$group_script no_analysis.txt") or die;
open (my $f_no_analysis_filtered, "|-", "$group_script no_analysis-without_77_88_G_Y_m.txt") or die;

my ($total, $full_matches, $unique, $multiple_uniquetag, $multiple_nonuniquetag, $no_analysis) = (0, 0, 0, 0, 0, 0);
my %no_analysis = ();
while (<>) {
  chomp;
  next if /^$/;
  my ($form, $lemma, $tag, $node) = split /\t/;
  $total++;
  if ($dictionary->analyze($form, $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $lemmas) < 0) {
    $no_analysis++;
    push @{$no_analysis{$lemma}->{"nodes"}}, $node;
    $no_analysis{$lemma}->{"formtag"}->{"$form $tag"}++;
    next;
  }

  my (@lemmas, @tags) = ();
  for (my ($i, $size) = (0, $lemmas->size()); $i < $size; $i++) {
    my $lemma_tag = $lemmas->get($i);
    push @lemmas, $lemma_tag->{lemma};
    push @tags, $lemma_tag->{tag};
  }

  # Full matches
  my $match = 0;
  for (my $i = 0; $i < @lemmas; $i++) {
    $match = $match || ($lemmas[$i] eq $lemma && $tags[$i] eq $tag);
  }
  $full_matches += $match;
  next if $match;

  # Get indices matching the raw lemma
  my @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $dictionary->rawLemma($lemmas[$i]) eq $dictionary->rawLemma($lemma);
    push @match_indices, $i;
  }

  # Unique replacements have either correct tag or full lemma
  if (@match_indices == 1 &&
      ($tags[$match_indices[0]] eq $tag || $lemmas[$match_indices[0]] eq $lemma)) {
    $unique++;
    print $f_unique "$node $form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }

  # If there is only single analysis, it is also a unique replacement
  if (@lemmas == 1) {
    $unique++;
    print $f_unique "$node $form $lemma $tag -> $lemmas[0] $tags[0]\n";
  } else {
    # Count matching tags
    my @match_indices = ();
    for (my $i = 0; $i < @lemmas; $i++) {
      next unless $tags[$i] eq $tag;
      push @match_indices, $i;
    }

    my $f_multiple_output;
    if (@match_indices == 1) {
      $multiple_uniquetag++;
      $f_multiple_output = $f_multiple_uniquetag;
    } else {
      $multiple_nonuniquetag++;
      $f_multiple_output = $f_multiple_nonuniquetag;
    }

    print $f_multiple_output "$node $form $lemma $tag ->";
    foreach my $i (@match_indices) {
      print $f_multiple_output " $lemmas[$i] $tags[$i]";
    }
    foreach my $i (0..$#lemmas) {
      next if $tags[$i] eq $tag;
      print $f_multiple_output " $lemmas[$i] $tags[$i]";
    }
    print $f_multiple_output "\n";
  }
}

foreach my $lemma (keys %no_analysis) {
  my $message = "$lemma";
  foreach my $formtag (sort {$no_analysis{$lemma}->{"formtag"}->{$b} <=> $no_analysis{$lemma}->{"formtag"}->{$a} } keys %{$no_analysis{$lemma}->{"formtag"}}) {
    $message .= "; $no_analysis{$lemma}->{'formtag'}->{$formtag} $formtag";
  }
  foreach my $node (@{$no_analysis{$lemma}->{"nodes"}}) {
    print $f_no_analysis "$node $message\n";
    print $f_no_analysis_filtered "$node $message\n" unless $lemma =~ /-77|-88|_;G|_;Y|_;m/;
  }
}

my $cummulative = 0;
printf "Full matches: %.2f%% (%d forms).\n", 100. * ($cummulative += $full_matches) / $total, $full_matches;
printf "Unique: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique / $total, $unique, 100. * ($cummulative += $unique) / $total;
printf "Multiple_uniquetag: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_uniquetag / $total, $multiple_uniquetag, 100. * ($cummulative += $multiple_uniquetag) / $total;
printf "Multiple_non-uniquetag: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_nonuniquetag / $total, $multiple_nonuniquetag, 100. * ($cummulative += $multiple_nonuniquetag) / $total;
printf "No analysis: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $no_analysis / $total, $no_analysis, 100. * ($cummulative += $no_analysis) / $total;
