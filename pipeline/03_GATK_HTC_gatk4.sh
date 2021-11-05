#!/bin/sh
#SBATCH --nodes 1 -p short
#SBATCH --ntasks 4
#SBATCH --mem 16gb
#SBATCH --time 2:00:00
#SBATCH --job-name HTC
#SBATCH --output=logs/HTC.%A_%a.out

module load java/8
module load gatk/4.0.8.1
module load picard

hostname

CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi

MEM=16g
GENOMEIDX=$GENOMEFOLDER/$GENOMEFASTA
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "Need a number via slurm array or on the cmdline"
	exit
    fi
fi

if [ -z $GVCFFOLDER ]; then
    echo "need a GVCFFOLDER variable in config.txt"
    GVCFFOLDER=gvcf
fi
mkdir -p $GVCFFOLDER

IFS=,
sed -n ${N}p $SAMPLESINFO | while read SAMPLE READ1 READ2 CTR
do
	IN=$ALNFOLDER/$SAMPLE.realign.bam

	if [ ! -f $GVCFFOLDER/$SAMPLE.g.vcf ]; then
		gatk --java-options -Xmx${MEM} HaplotypeCaller \
		  -ERC GVCF \
		  -ploidy 1 \
		  -I $IN -R $GENOMEIDX \
		  -O $GVCFFOLDER/$SAMPLE.g.vcf \
		  --native-pair-hmm-threads $CPU
	fi
	module load bcftools
	bgzip $GVCFFOLDER/$SAMPLE.g.vcf
	tabix $GVCFFOLDER/$SAMPLE.g.vcf.gz
done
