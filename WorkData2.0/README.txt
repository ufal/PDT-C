PDT-C 2.0 (Prague Dependency Treebank - Consolidated 2.0)

See https://ufal.mff.cuni.cz/pdt-c for the full documentation.

All data are provided in three different formats.

- PML (Prague Markup Language): the native format of the treebank. Each
  document is represented by four files corresponding to four layers: t-layer
  (tectogrammatics), a-layer (analytics, surface syntax), m-layer (morphology)
  and w-layer (word layer, tokenised text). See https://ufal.mff.cuni.cz/pml
  for details.

- Treex: The format used by the Treex framework. Technically, it's also a PML
  format, but all the layers are merged into a single file. See
  https://ufal.mff.cuni.cz/treex for details.

- MRP (Meaning Representation Parsing) is a JSON-based format used at the 2019
  and 2020 CoNLL Shared Task, see https://aclanthology.org/K19-2001/. Note
  that the conversion to MRP is lossy, e.g. morphological and surface syntax
  are discarded.

All data are divided into "train", "dtest", and "etest" subdirectories:

- "train" should be used as the training data,

- "dtest" is the development testing data,

- "etest" is the evaluation testing data (you should never investigate what
  your tools do to this part of the data).

* Faust/

A small treebank of user-generated text from the FAUST project, see
https://ufal.mff.cuni.cz/grants/faust for details.

* PCEDT-cz/

The Czech part of the parallel Czech-English Treebank based on the texts from
the Penn Treebank's Wall Street Journal Section.

* PDT

Newspaper texts from the Prague Dependency Treebank. The subdirectories
"tamw", "amw", and "mw" indicate which annotation layers exist.

* PDTSC

Spoken corpus data (spontaneous dialog).

Comparing to PDT-C 1.0, the filenames have been unified. The file pdtsc.map
lists the mapping between the old and new names.

The audio is stored in a separate ogg/ directory. Besides the usual four
annotation layers, there are also the following additional files:

- zdata: automatically recognised words from the audio;

- wdata: manually corrected word-to-word transcriptions of the audio;

- mdata: several versions of "reconstructed" texts. For each document, there
  are 2 or three such texts, only one is used for further annotation.

* dictionaries/

Contains the PDT Valency Lexicon version 4.5 (the file "vallex.changes" maps
the version 4.0 identifiers to the new identifiers used in 4.5) and the Czech
morphological dictionary (morfflex) version 2.1.


All data are provided under the Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 license (CC BY-NC-SA 4.0).
