#!/usr/bin/bash
#SBATCH --mem 48gb --nodes 1 --ntasks 48 -J GATK.GVCFGeno --out logs/GVCFGeno.log 

MEM=48g
module load java/8
module load gatk/4.0.4.0 
module load picard
module load parallel
module unload perl

hostname

CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi
GENOME=$GENOMEFOLDER/$GENOMEFASTA
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi
if [ ! -f $GENOME.fai ]; then
	module load samtools
	samtools faidx $GENOME
fi
if [ -z $GVCFFOLDER ]; then
	echo "Need GVCFFOLDER variable for input"
	exit
fi

if [ -z $VARIANTFOLDER ]; then
	echo "Need VARIANTFOLDER for output"
	exit
fi
mkdir -p $VARIANTFOLDER
OUT=$VARIANTFOLDER/Exophiala.Run1.vcf
OUTCOMBO=$VARIANTFOLDER/Exophiala.Run1.combined.g.vcf

CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then
 CPU=2
fi
if [[ $(ls $GVCFFOLDER | grep -c -P "\.g.vcf$") -gt "0" ]]; then
	parallel -j $CPU bgzip {} ::: $GVCFFOLDER/*.g.vcf
	parallel -j $CPU tabix -f {} ::: $GVCFFOLDER/*.g.vcf.gz
fi

N=$(ls -S $GVCFFOLDER/*.g.vcf.gz | sort | perl -p -e 's/(\S+)\n/-V $1 /')
INTERVALS=$(cut -f1 $GENOME.fai  | perl -p -e 's/(\S+)\n/--intervals $1 /g')

DB=gvcf_db
#rm -rf $DB
gatk GenomicsDBImport --genomicsdb-workspace-path $DB $N $INTERVALS

if [ ! -f $OUT ]; then
	gatk --java-options -Xmx${MEM} GenotypeGVCFs -R $GENOME -V gendb://$DB --output $OUT --sample-ploidy 1
fi
