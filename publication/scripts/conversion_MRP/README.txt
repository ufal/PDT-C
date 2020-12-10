
Konverzi z formátu Treex do formátu MRP prováděl Dan Zeman, s tímto komentářem:


Převod z Treexu do MRP (akorát tu substituci v cestě jsem ve skutečnosti měl jinou, protože jsem psal k sobě):

treex -Lcs Read::Treex from='!/net/work/projects/PDT-C/github-PDT-C/publication/PDT-C/data/{Faust,PCEDT,PDTSC}/treex/*.treex.gz' Write::MrpJSON substitute={treex}{mrp}
treex -Lcs Read::Treex from='!/net/work/projects/PDT-C/github-PDT-C/publication/PDT-C/data/PDT/treex/tamw/{train-1,train-2,train-3,train-4,train-5,train-6,train-7,train-8,dtest,etest}/*.treex.gz' Write::MrpJSON substitute={treex}{mrp}

Počet grafů včetně prázdných:

cat {Faust,PCEDT,PDTSC}/mrp/*.mrp PDT/mrp/tamw/*/*.mrp | wc -l
175471


Validace

( for i in PDT/mrp/tamw/*/*.mrp {PCEDT,PDTSC,Faust}/mrp/*.mrp ; do echo $i ; /lnet/spec/work/projects/mrptask/mtool/main.py --read mrp --validate all $i ; done ) |& tee validation.log


