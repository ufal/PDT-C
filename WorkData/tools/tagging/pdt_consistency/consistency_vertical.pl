#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

use Ufal::MorphoDiTa;

@ARGV >= 1 or die "Usage: $0 dictionary_file\n";

print STDERR "Loading dictionary: ";
my $dictionary = Ufal::MorphoDiTa::Morpho::load($ARGV[0]);
$dictionary or die "Cannot load dictionary from file '$ARGV[0]'\n";
print STDERR "done\n";
shift @ARGV;

my $lemmas = Ufal::MorphoDiTa::TaggedLemmas->new();

open (my $f_unique_lemma_comment_change, "|-", "LC_COLLATE=cs_CZ sort -u >unique-lemma_comment_change.txt") or die;
open (my $f_unique_lemma_sense_change, "|-", "LC_COLLATE=cs_CZ sort -u >unique-lemma_sense_change.txt") or die;
open (my $f_unique_tag_change, "|-", "LC_COLLATE=cs_CZ sort -u >unique-tag_change.txt") or die;
open (my $f_unique_rest, "|-", "LC_COLLATE=cs_CZ sort -u >unique-rest.txt") or die;
open (my $f_multiple_lemma_comment_change, "|-", "LC_COLLATE=cs_CZ sort -u >multiple-lemma_comment_change.txt") or die;
open (my $f_multiple_lemma_sense_change, "|-", "LC_COLLATE=cs_CZ sort -u >multiple-lemma_sense_change.txt") or die;
open (my $f_multiple_tag_change, "|-", "LC_COLLATE=cs_CZ sort -u >multiple-tag_change.txt") or die;
open (my $f_multiple_rest, "|-", "LC_COLLATE=cs_CZ sort -u >multiple-rest.txt") or die;

my ($total, $full_matches, $unique_lemma_comment_change, $unique_lemma_sense_change, $unique_tag_change, $unique_rest) = (0, 0, 0, 0, 0, 0);
my ($multiple_lemma_comment_change, $multiple_lemma_sense_change, $multiple_tag_change, $multiple_rest, $no_analysis) = (0, 0, 0, 0, 0);
while (<>) {
  chomp;
  next if /^$/;
  my ($form, $lemma, $tag) = split /\t/;
  $total++;
  if ($dictionary->analyze($form, $Ufal::MorphoDiTa::Morpho::NO_GUESSER, $lemmas) < 0) {
    $no_analysis++;
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

  # Lemma comment change
  my @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $tags[$i] eq $tag && $dictionary->lemmaId($lemmas[$i]) eq $dictionary->lemmaId($lemma);
    push @match_indices, $i;
  }
  if (@match_indices == 1) {
    $unique_lemma_comment_change++;
    print $f_unique_lemma_comment_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices > 1) {
    $multiple_lemma_comment_change++;
    print $f_multiple_lemma_comment_change "$form $lemma $tag ->";
    foreach my $i (@match_indices) {
      print $f_multiple_lemma_comment_change " $lemmas[$i] $tags[$i]";
    }
    print $f_multiple_lemma_comment_change "\n";
    next;
  }

  # Lemma sense change
  @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $tags[$i] eq $tag && $dictionary->rawLemma($lemmas[$i]) eq $dictionary->rawLemma($lemma);
    push @match_indices, $i;
  }
  if (@match_indices == 1) {
    $unique_lemma_sense_change++;
    print $f_unique_lemma_sense_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices > 1) {
    $multiple_lemma_sense_change++;
    print $f_multiple_lemma_sense_change "$form $lemma $tag ->";
    foreach my $i (@match_indices) {
      print $f_multiple_lemma_sense_change " $lemmas[$i] $tags[$i]";
    }
    print $f_multiple_lemma_sense_change "\n";
    next;
  }

  # Tag change
  @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $lemmas[$i] eq $lemma;
    push @match_indices, $i;
  }
  if (@match_indices == 1) {
    $unique_tag_change++;
    print $f_unique_tag_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices > 1) {
    $multiple_tag_change++;
    print $f_multiple_tag_change "$form $lemma $tag ->";
    foreach my $i (@match_indices) {
      print $f_multiple_tag_change " $lemmas[$i] $tags[$i]";
    }
    print $f_multiple_tag_change "\n";
    next;
  }

  # Rest changes
  if (@lemmas == 1) {
    $unique_rest++;
    print $f_unique_rest "$form $lemma $tag -> $lemmas[0] $tags[0]\n";
  } else {
    $multiple_rest++;
    print $f_multiple_rest "$form $lemma $tag ->";
    foreach my $i (0..$#lemmas) {
      print $f_multiple_rest " $lemmas[$i] $tags[$i]";
    }
    print $f_multiple_rest "\n";
  }
}

my $cummulative = 0;
printf "Full matches: %.2f%% (%d forms).\n", 100. * ($cummulative += $full_matches) / $total, $full_matches;
printf "Unique lemma_comment_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique_lemma_comment_change / $total, $unique_lemma_comment_change, 100. * ($cummulative += $unique_lemma_comment_change) / $total;
printf "Unique lemma_sense_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique_lemma_sense_change / $total, $unique_lemma_sense_change, 100. * ($cummulative += $unique_lemma_sense_change) / $total;
printf "Unique tag_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique_tag_change / $total, $unique_tag_change, 100. * ($cummulative += $unique_tag_change) / $total;
printf "Unique rest: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique_rest / $total, $unique_rest, 100. * ($cummulative += $unique_rest) / $total;
printf "Multiple lemma_comment_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_lemma_comment_change / $total, $multiple_lemma_comment_change, 100. * ($cummulative += $multiple_lemma_comment_change) / $total;
printf "Multiple lemma_sense_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_lemma_sense_change / $total, $multiple_lemma_sense_change, 100. * ($cummulative += $multiple_lemma_sense_change) / $total;
printf "Multiple tag_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_tag_change / $total, $multiple_tag_change, 100. * ($cummulative += $multiple_tag_change) / $total;
printf "Multiple rest: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_rest / $total, $multiple_rest, 100. * ($cummulative += $multiple_rest) / $total;
printf "No analysis: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $no_analysis / $total, $no_analysis, 100. * ($cummulative += $no_analysis) / $total;
