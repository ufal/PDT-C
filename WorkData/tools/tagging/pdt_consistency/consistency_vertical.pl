#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

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

open (my $f_uniquelemma_comment_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >uniquelemma_comment_change.txt") or die;
open (my $f_uniquelemma_resensed_comment_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >uniquelemma_resensed_comment_change.txt") or die;
open (my $f_uniquelemma_sense_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >uniquelemma_sense_change.txt") or die;
open (my $f_uniquelemma_tag_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >uniquelemma_tag_change.txt") or die;
open (my $f_unique_rest, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >unique_rest.txt") or die;
open (my $f_multiplelemma_sense_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >multiplelemma_sense_change.txt") or die;
open (my $f_multiplelemma_tag_change, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >multiplelemma_tag_change.txt") or die;
open (my $f_multiple_rest, "|-", "LC_COLLATE=cs_CZ sort | uniq -c | LC_COLLATE=cs_CZ sort -nrk1,1 -s >multiple_rest.txt") or die;

my ($total, $full_matches, $uniquelemma_resensed_comment_change, $uniquelemma_comment_change, $uniquelemma_sense_change) = (0, 0, 0, 0, 0);
my ($uniquelemma_tag_change, $unique_rest, $multiplelemma_sense_change, $multiplelemma_tag_change, $multiple_rest, $no_analysis) = (0, 0, 0, 0, 0, 0);
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

  # Get indices matching the raw lemma
  my @match_indices = ();
  for (my $i = 0; $i < @lemmas; $i++) {
    next unless $dictionary->rawLemma($lemmas[$i]) eq $dictionary->rawLemma($lemma);
    push @match_indices, $i;
  }

  # Unique replacements
  if (@match_indices == 1 && $tags[$match_indices[0]] eq $tag && $dictionary->lemmaId($lemmas[$match_indices[0]]) eq $dictionary->lemmaId($lemma)) {
    $uniquelemma_comment_change++;
    print $f_uniquelemma_comment_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices == 1 && $tags[$match_indices[0]] eq $tag && $dictionary->lemmaId($lemmas[$match_indices[0]]) eq ($resensing{$dictionary->lemmaId($lemma)} || "")) {
    $uniquelemma_resensed_comment_change++;
    print $f_uniquelemma_resensed_comment_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices == 1 && $tags[$match_indices[0]] eq $tag) {
    $uniquelemma_sense_change++;
    print $f_uniquelemma_sense_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }
  if (@match_indices == 1 && $lemmas[$match_indices[0]] eq $lemma) {
    $uniquelemma_tag_change++;
    print $f_uniquelemma_tag_change "$form $lemma $tag -> $lemmas[$match_indices[0]] $tags[$match_indices[0]]\n";
    next;
  }

  # Multiple replacements
  if (@match_indices > 1) {
    my $all_matches = 1;
    foreach my $i (@match_indices) {
      $all_matches = 0 unless $tags[$i] eq $tag && $dictionary->rawLemma($lemmas[$i]) eq $dictionary->rawLemma($lemma);
    }
    if ($all_matches) {
      $multiplelemma_sense_change++;
      print $f_multiplelemma_sense_change "$form $lemma $tag ->";
      foreach my $i (@match_indices) {
        print $f_multiplelemma_sense_change " $lemmas[$i] $tags[$i]";
      }
      print $f_multiplelemma_sense_change "\n";
      next;
    }

    $all_matches = 1;
    foreach my $i (@match_indices) {
      $all_matches = 0 unless $dictionary->lemmaId($lemmas[$i]) eq $dictionary->lemmaId($lemma);
    }
    if ($all_matches) {
      $multiplelemma_tag_change++;
      print $f_multiplelemma_tag_change "$form $lemma $tag ->";
      foreach my $i (@match_indices) {
        print $f_multiplelemma_tag_change " $lemmas[$i] $tags[$i]";
      }
      print $f_multiplelemma_tag_change "\n";
      next;
    }
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
printf "Uniquelemma_comment_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $uniquelemma_comment_change / $total, $uniquelemma_comment_change, 100. * ($cummulative += $uniquelemma_comment_change) / $total;
printf "Uniquelemma_resensed_comment_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $uniquelemma_resensed_comment_change / $total, $uniquelemma_resensed_comment_change, 100. * ($cummulative += $uniquelemma_resensed_comment_change) / $total;
printf "Uniquelemma_sense_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $uniquelemma_sense_change / $total, $uniquelemma_sense_change, 100. * ($cummulative += $uniquelemma_sense_change) / $total;
printf "Uniquelemma_tag_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $uniquelemma_tag_change / $total, $uniquelemma_tag_change, 100. * ($cummulative += $uniquelemma_tag_change) / $total;
printf "Unique rest: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $unique_rest / $total, $unique_rest, 100. * ($cummulative += $unique_rest) / $total;
printf "Multiplelemma_sense_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiplelemma_sense_change / $total, $multiplelemma_sense_change, 100. * ($cummulative += $multiplelemma_sense_change) / $total;
printf "Multiplelemma_tag_change: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiplelemma_tag_change / $total, $multiplelemma_tag_change, 100. * ($cummulative += $multiplelemma_tag_change) / $total;
printf "Multiple rest: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $multiple_rest / $total, $multiple_rest, 100. * ($cummulative += $multiple_rest) / $total;
printf "No analysis: %.2f%% (%d forms) (cummulative %.2f%%).\n", 100. * $no_analysis / $total, $no_analysis, 100. * ($cummulative += $no_analysis) / $total;
