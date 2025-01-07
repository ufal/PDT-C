PDT-C 2.0 (Prague Dependency Treebank - Consolidated 2.0)

All data are divided into "train", "dtest", and "etest" subdirectories:
- "train" should be used as the training data,
- "dtest" is the development testing data,
- "etest" is the evaluation testing data (you should never investigate what
your tools do to this part of the data).

* Faust/

A small treebank from the Faust MT project.

* PCEDT-cz/

The Czech part of the parallel Czech-English Treebank based on the texts from
the Wall Street Journal.

* PDT

Newspaper texts from the Prague Dependency Treebank. The subdirectories
"tamw", "amw", and "mw" indicate which annotation layers exist.

* PDTSC

Spoken corpus data. Comparing to PDT-C 1.0, the filenames have been unified.
The file pdtsc.map lists the mapping between the old and new names.

The audio is stored in a separate ogg/ directory. Besides the usual four
annotation layers, there are also the following additional files:
- zdata: automatically recognised words from the audio;
- wdata: manually corrected word-to-word transcriptions of the audio;
- mdata: several versions of "reconstructed" texts. For each document, there
are 2 or three such texts, only one is used for further annotation.

* dictionaries/

Contains the PDT Valency Lexicon version 4.5. The file "vallex.changes"
maps the version 4.0 identifiers to the new identifiers used in 4.5.
