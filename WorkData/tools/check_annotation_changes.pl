#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  check_annotation_changes.pl
#
#        USAGE:  git diff PDT/data/ | tools/check_annotation_changes.pl 
#
#  DESCRIPTION:  Check all differences between original file
#                and the one returned by an annotator
#                and report any not expected pattern
#
#                It's rather conservative and many possible but not seen
#                patterns are not recognised either. Moreover, the code could
#                be much concise but I value the examples of XML patterns near
#                each case more.
#
#      OPTIONS:  None
#       AUTHOR:  Eduard Bejcek, <bejcek@ufal.mff.cuni.cz>
#      COMPANY:  UFAL MFF UK
#      CREATED:  10/03/2019 08:04:26 AM CEST
#=======================================.vim/plugin/templates/perl-file-header==

use strict;
use warnings;

use open qw(:std :utf8);
utf8::decode($_) foreach (@ARGV);	# ARGV is assumed to be in UTF-8
use Readonly;

#local $| = 1;  # autoflush after every print()

my $REMOVE_ONELINE_TAG = qr{ -<tag\ lemma.*\n}x;
my $ADD_ONELINE_TAG =    qr{\+<tag\ lemma.*\n}x;
my $REMOVE_LEMMA = qr{ -<AM\ lemma.*\n}x; 
my $ADD_LEMMA =    qr{\+<AM\ lemma.*\n}x;
my $ADD_MULTILINE_TAG = qr{
	\+<tag>\n
	(?: $ADD_LEMMA )+
	\+</tag>\n
}x;
my $NEW_FORM = qr{
	\+<comment>\n
	\+<LM\ type="New\ Form">\n
	\+<text>.*\n
	\+</LM>\n
	\+</comment>\n
}x;
my $OTHER_COMMENT = qr{
	\+<comment>\n
	\+<LM\ type="Other">\n
	\+<text>.*\n
	\+</LM>\n
	\+</comment>\n
}x;
my $MORE_OTHER_COMMENTS = qr{
	\+<comment>\n
	\+<LM\ type="Other">\n
	\+<text>.*\n
	\+</LM>\n
	\+<LM\ type="Other">\n
	\+<text>.*\n
	\+</LM>\n
	\+</comment>\n
}x;
my $NEW_FORM_AND_COMMENT = qr{
	\+<comment>\n
	\+<LM\ type="New\ Form">\n
	\+<text>.*\n
	\+</LM>\n
	\+<LM\ type="Other">\n
	\+<text>.*\n
	\+</LM>\n
	\+</comment>\n
}x;

sub examine_change {
	my $change = shift;

	return if !$change;

	# Pridani (vice) anotaci k jedine:
	# -<tag lemma="Kapfinger_;K" src="orig" selected="1">NNMS1-----A----</tag>
	# +<tag>
	# +<AM lemma="Kapfinger_;K" src="orig">NNMS1-----A----</AM>
	# +<AM lemma="Kapfinger-77" src="manual">F%-------------</AM>
	# +<AM lemma="Kapfinger_;S" src="manual" selected="1">NNMS1-----A----</AM>
	# +</tag>
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_MULTILINE_TAG
	$}x;

	# Zvoleni doporucene anotace:
	#  <tag>
	#  <AM lemma="totiž" src="orig">Db-------------</AM>
	# -<AM lemma="totiž-1" src="auto" recommended="1">J^-------------</AM>
	# +<AM lemma="totiž-1" src="auto" recommended="1" selected="1">J^-------------</AM>
	#  <AM lemma="totiž-2" src="auto">TT-------------</AM>
	#  </tag>
	return if $change =~ m{^
		$REMOVE_LEMMA
		$ADD_LEMMA
	$}x;
	return if $change =~ m{^
		$REMOVE_LEMMA
		(?: $ADD_LEMMA )+
	$}x;

	# Pridani anotaci k vice:
	#  <tag>
	#  <AM lemma="emo-1_,h_,l_^(styl)" src="auto">NNNP2-----A----</AM>
	# +<AM lemma="em-99_:B_;S" src="manual" selected="1">NNXXX-----A----</AM>
	#  </tag>
	#  <tag>
	#  <AM lemma="prey_;R_,t" src="orig">NNFXX-----A----</AM>
	#  <AM lemma="Prey_;S" src="auto" recommended="1">NNMS1-----A----</AM>
	# +<AM lemma="prey_,t" src="manual">NNXXX-----A----</AM>
	# +<AM lemma="Prey-77" src="manual" selected="1">F%-------------</AM>
	#  </tag>
	return if $change =~ m{^
		(?: $ADD_LEMMA )+
	$}x;

	# Zruseni doporuceni a pridani zmeny formy
	# -<tag lemma="konstatovat_:T_:W" src="orig" selected="1">VpQW---XR-AA---</tag>
	# +<tag lemma="konstatovat_:T_:W" src="orig">VpQW---XR-AA---</tag>
	# +<comment>
	# +<LM type="New Form">
	# +<text>Konstatovala</text>
	# +</LM>
	# +</comment>
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_ONELINE_TAG
	$}x;

	# Jen pridani zmeny formy
	# +<comment>
	# +<LM type="New Form">
	# +<text>žádná</text>
	# +</LM>
	# +</comment>
	return if $change =~ m{^
		$NEW_FORM
	$}x;

	# Jen pridani poznamky
	# +<comment>
	# +<LM type="Other">
	# +<text>nejsem si jistý, zda to do toho textu patří, nedává to tu smysl</text>
	# +</LM>
	# +</comment>
	return if $change =~ m{^
		$OTHER_COMMENT
	$}x;
	# Nebo poznamek
	return if $change =~ m{^
		$MORE_OTHER_COMMENTS
	$}x;
	# Nebo nove formy a poznamky
	return if $change =~ m{^
		$NEW_FORM_AND_COMMENT
	$}x;

	# Kombinace
	# -<tag lemma="Alfa_;K_;R_^(vozidlo)" src="auto" selected="1">NNFS1-----A----</tag>
	# +<tag>
	# +<AM lemma="Alfa_;K_;R_^(vozidlo)" src="auto">NNFS1-----A----</AM>
	# +<AM lemma="Alfa_;K_;R" src="manual" selected="1">NNFS1-----A----</AM>
	# +</tag>
	# +<comment>
	# +<LM type="Other">
	# +<text>návrh na vymazání poznámky - zde nejde o vozidlo, ale o kino</text>
	# +</LM>
	# +</comment>
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_MULTILINE_TAG
		$OTHER_COMMENT
	$}x;
	# Jina kombinace
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_ONELINE_TAG
		$NEW_FORM
	$}x;
	# Jina kombinace
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_ONELINE_TAG
		$NEW_FORM_AND_COMMENT
	$}x;
	return if $change =~ m{^
		$REMOVE_ONELINE_TAG
		$ADD_MULTILINE_TAG
		$NEW_FORM
	$}x;


	print "DIVNE:\n$change";
}

my $change = "";
while (<>) {
	next if /^---/;
	print $1 and next if m{^\+\+\+ b/(.*\n)};

	if (/^[^+-]/) {
		examine_change($change);
		$change = "";
		next;
	}
	$change .= $_;
}

