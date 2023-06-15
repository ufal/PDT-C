#! /bin/bash

fail() {
    printf '%s\n' "$@" >&2
    exit 1
}

script_dir=${0%/*}

ls -d annotators/???/done > /dev/null || fail 'Wrong working directory'

out1=auxz-adv-t.l
if [[ ! -f $out1 ]] ; then
    btred -qI "$script_dir"/auxz-adv.btred annotators/???/done/*.t | tee $out1
fi

out2=auxz-adv-a.l
if [[ ! -f $out2 ]] ; then
    FUNCTORS=$out1 btred -qI "$script_dir"/auxz-adv2.btred \
                   annotators/???/done/*.a | tee $out2
fi
