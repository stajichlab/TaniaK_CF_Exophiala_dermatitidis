#!/usr/bin/bash
#SBATCH -J FreeBayes --out logs/freebayes.%a.log --ntasks 36 --nodes 1 --mem 64G
#SBATCH --time 3-0:0:0

module unload java
module load java/8
module load freebayes
module load bcftools/1.9
module load samtools/1.9
module load picard
module load tabix
module load parallel
module load vcftools

MEM=64g

ALNFOLDER=aln
VARIANTFOLDER=freebayes_gvcf
HTCFORMAT=bam #default but may switch back to bam
HTCFOLDER=bam # default
HTCEXT=bam
if [ -f config.txt ]; then
    source config.txt
fi
DICT=$(echo $REFGENOME | sed 's/fasta$/dict/')

if [ ! -f $DICT ]; then
	picard CreateSequenceDictionary R=$GENOMEIDX O=$DICT
fi
mkdir -p $VARIANTFOLDER
TEMP=/scratch
VARIANTFOLDER=freebayes_gvcf
 
time freebayes-parallel regions.bed $CPU --gvcf -f $REFGENOME -L bam.list > freebayes_all.g.vcf

