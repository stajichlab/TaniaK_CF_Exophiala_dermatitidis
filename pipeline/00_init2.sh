#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/init.log

# EXPECTED VARIABLES
GENOMEFOLDER=genome
GENOMEFASTA=Exophiala_dermatitidis_Ex4.fa
GENOMENAME=Exophiala_dermatitidis_Ex4
CONFIG=config.txt

if [ -f $CONFIG ]; then
     source $CONFIG
fi
# make sure log file forlder is setup
mkdir -p logs

module load bwa/0.7.17
module load samtools/1.8
module load picard
mkdir -p $GENOMEFOLDER

#if [ ! -f $GENOMEFOLDER/$GENOMEFASTA ]; then
#        pushd $GENOMEFOLDER
#        curl -O ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/230/625/GCF_00023062$
#        gunzip GCF_000230625.1_Exop_derm_V1_genomic.fna.gz
#        ln -s GCF_000230625.1_Exop_derm_V1_genomic.fna $GENOMEFASTA
#        popd
#fi
if [ ! -f $GENOMEFOLDER/$GENOMENAME.sa ]; then
    bwa index -p $GENOMEFOLDER/$GENOMENAME $GENOMEFOLDER/$GENOMEFASTA
fi

if [ ! -e $GENOMEFOLDER/$GENOMENAME.fasta.fai ]; then
        samtools faidx $GENOMEFOLDER/$GENOMENAME.fa
fi

if [ ! -e $GENOMEFOLDER/$GENOMENAME.dict ]; then
	 picard CreateSequenceDictionary R=$GENOMEFOLDER/$GENOMENAME.fa O=$GENOMEFOLDER/$GENOMENAME.dict SPECIES=Exophalia_dermatitidis TRUNCATE_NAMES_AT_WHITESPACE=true
fi

