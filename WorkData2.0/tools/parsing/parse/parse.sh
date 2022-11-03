#!/bin/sh

DATADIR=$PWD

cd /home/straka/repos/udpipe_pdtc
MODEL=$(echo logs/ud_parser.py*is_mpr*)
withcuda90 venv/bin/python ud_parser.py $(cat $MODEL/cmd) --threads=4 --checkpoint="$MODEL/checkpoint-inference-last" --predict --predict_input="$DATADIR/input.conllu" --elmo="$DATADIR/input.conllu.npz" --predict_output="$DATADIR/output.conllu"
