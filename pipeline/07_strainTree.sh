#!/usr/bin/bash

#SBATCH --nodes 1 --ntasks 2 -p short --mem 8gb --out logs/make_tree.IQ.log

module load IQ-TREE/2.0.4
module load vcftools
module unload perl
module unload miniconda2
module load miniconda3
TREEFOLDER=Strain_tree_2
SCRIPTSDIR=scripts
CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi

if [ -z $PREFIX ]; then
    echo "Need a PREFIX variable in config.txt"
    exit
fi
mkdir -p $TREEFOLDER

if [ ! -f $TREEFOLDER/$PREFIX.SNPs_FILTERED.fasaln ]; then
    vcf-to-tab < $VARIANTFOLDER/$PREFIX.selected_nofixed.SNP_CLEANING.vcf > $VARIANTFOLDER/$PREFIX.selected_nofixed.SNP_CLEANING.tab
    perl scripts/vcftab_to_fasta.pl --nosingletons --nomissing --noinvariants --refstrain Ex4REF $VARIANTFOLDER/$PREFIX.selected_nofixed.SNP_CLEANING.tab -o $TREEFOLDER/$PREFIX.SNPs_CLEANING.fasaln
fi

iqtree2 -nt 2 -s $TREEFOLDER/$PREFIX.SNPs_CLEANING.fasaln -m GTR+ASC  -b 100
