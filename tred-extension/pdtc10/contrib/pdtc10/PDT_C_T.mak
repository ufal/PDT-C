# -*- cperl -*-

#ifndef PDT_C_T
#define PDT_C_T

#include <contrib/pml/PML_T_View.mak>

package PDT_C_T;

#binding-context PDT_C_T

#include "PDT_C_T.inc"

#key-binding-adopt PML_T_View
#menu-binding-adopt PML_T_View
#unbind-key A
#remove-menu Toggle display of a-nodes or grammatemes
# (we will redefine this below)

#include <contrib/support/unbind_edit.inc>

#bind AnalyticalTree to Ctrl+A menu Display corresponding analytical tree
#bind toggle_clause_coloring to c menu Toggle clause coloring on/off
#bind toggle_mwe_folding to f menu Toggle multiword-entity folding on/off
#bind toggle_legend to l menu Toggle Legend

#bind toggle_displaying_discourse to d menu Toggle displaying discourse
#bind toggle_displaying_coref_text to t menu Toggle displaying coref_text
#bind toggle_displaying_bridging to b menu Toggle displaying bridging
#bind toggle_displaying_t_lemma_trans to Ctrl+t menu Toggle displaying t_lemma translations
#bind toggle_displaying_t_root_id to Ctrl+r menu Toggle displaying t_root id
#bind toggle_displaying_tfa to Ctrl+f menu Toggle displaying tfa

#bind toggle_displaying_a_nodes_grams to A menu Toggle displaying grammatemes or a-nodes
# (overloaded from PML_T)

1;

#endif PDT_C_T
