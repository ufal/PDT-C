#!/bin/bash

src_en_dir=$1
src_cs_dir=$2
trg_dir=$3

mkdir -p $trg_dir
for j in `find $src_cs_dir -name 'wsj*.[wmat].gz' | sort`; do
    src_file=`basename $j`;
    src_base=`echo $src_file | sed 's/\..*$//'`;
    trg_file=`echo $src_file | sed 's/\.cz\./.cs./'`;
    trg_base=`echo $trg_file | sed 's/\..*$//'`;
    echo $j "--->" $trg_dir/$trg_file;
    zcat $j | \
        sed "s/$src_base\.cz\.\([atmw]\)/$trg_base.cs.\1/g" | \
        gzip -c > $trg_dir/$trg_file;
done;
for j in `find $src_en_dir -name 'wsj*.[pat].gz' | sort`; do
    src_file=`basename $j`;
    src_base=`echo $src_file | sed 's/\..*$//'`;
    trg_file=`echo $src_file | sed 's/^wsj_\(....\)\.\(.\)\.gz$/wsj\1.en.\2.gz/'`;
    trg_base=`echo $trg_file | sed 's/\..*$//'`;
    echo $j "--->" $trg_dir/$trg_file;
    zcat $j | \
        sed "s/$src_base\.\([aptmw]\)\.gz/$trg_base.en.\1.gz/g" | \
        sed 's/target-node\.rf/target_node.rf/g' | \
        sed 's/informal-type/type/g' | \
        gzip -c > $trg_dir/$trg_file;
done;
