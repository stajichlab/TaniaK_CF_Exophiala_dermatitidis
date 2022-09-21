#!/usr/bin/bash
#SBATCH -J FreeBayes --out logs/freebayes.%a.log --ntasks 8 --nodes 1 --mem 16G
#SBATCH --time 1-0:0:0

module unload java
module load java/8
module load freebayes
module load bcftools/1.9
module load samtools/1.9
module load picard
module load tabix

MEM=32g

ALNFOLDER=aln
VARIANTFOLDER=freebayes_gvcf
HTCFORMAT=bam #default but may switch back to bam
HTCFOLDER=bam # default
HTCEXT=bam
if [ -f config.txt ]; then
    source config.txt
fi
DICT=$(echo $REFGENOME | sed 's/fa$/dict/')

if [ ! -f $DICT ]; then
	picard CreateSequenceDictionary R=$GENOMEIDX O=$DICT
fi
mkdir -p $VARIANTFOLDER
TEMP=/scratch
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then 
 echo "need to provide a number by --array slurm or on the cmdline"
 exit
fi

REGION=$(head -n $N regions.10000.bed | tail -n 1)
echo $REGION

VARIANTFOLDER=freebayes_gvcf.10000

if [ ! -f $VARIANTFOLDER/$REGION.g.vcf.gz ]; then
    if [ ! -f $VARIANTFOLDER/$REGION.g.vcf ]; then
	echo $VARIANTFOLDER/$REGION.g.vcf.gz

	freebayes -f $REFGENOME --region $REGION --gvcf -L bam.list > $VARIANTFOLDER/$REGION.g.vcf
	
    fi
    if [ -f $VARIANTFOLDER/$REGION.g.vcf ]; then
	bgzip $VARIANTFOLDER/$REGION.g.vcf
	tabix $VARIANTFOLDER/$REGION.g.vcf.gz
    fi
fi
