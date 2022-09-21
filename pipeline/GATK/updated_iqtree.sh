#!/usr/bin/bash

#SBATCH --nodes 1 --ntasks 2 -p short --mem 8gb --out logs/updated.make_tree.IQ.log

module load IQ-TREE/2.0.4
module load vcftools
module unload perl
module unload miniconda2
module load miniconda3
TREEFOLDER=Strain_tree_update
SCRIPTSDIR=scripts
CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi

if [ -z $PREFIX ]; then
    echo "Need a PREFIX variable in config.txt"
    exit
fi


#iqtree2 -nt 2 -s $TREEFOLDER/Exophiala.Run1.selected_nofixed.SNP_CLEANING_Filter4step.fasaln -m GTR+ASC  -b 100
iqtree2 -nt 2 -s $TREEFOLDER/Exophiala.Run1.selected_nofixed.SNP_CLEANING_Filter4step_removedExREF.fasaln -m GTR+ASC -b 100
