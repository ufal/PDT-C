#!/bin/sh

DATADIR=$PWD

cd /home/straka/repos/udpipe_pdtc/robeczech
withcuda101 venv/bin/python compute_wembeddings.py --format=conllu --model=noeol-210409 $DATADIR/input.conllu $DATADIR/input.conllu.npz
