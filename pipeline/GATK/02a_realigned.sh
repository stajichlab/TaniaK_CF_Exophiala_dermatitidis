#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH  --mem=32G
#SBATCH --job-name realign
#SBATCH --output=logs/realign.%a.log

module load java/8
module load gatk/3.7
module load picard

RGCENTER=MyCenter
RGPLATFORM=Illumina

CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
fi

MEM=32g
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME

BAMDIR=$ALNFOLDER
KNOWNSITES=
if [ ! -e $GENOMEFOLDER/$GENOMENAME.dict ]; then
    picard CreateSequenceDictionary R=$GENOMEFOLDER/$GENOMENAME.fa O=$GENOMEFOLDER/$GENOMENAME.dict SPECIES=Exophalia_dermatitidis TRUNCATE_NAMES_AT_WHITESPACE=true

fi

if [ ! $CPU ]; then
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

IFS=,
sed -n ${N}p $SAMPLESINFO | while read SAMPLE READ1 READ2 CTR
do
    if [[ $GENOMEIDX.fa -nt $BAMDIR/$SAMPLE.DD.bam ]]; then
	    rm $BAMDIR/$SAMPLE.DD.bam
    fi
    if [ ! -e $BAMDIR/$SAMPLE.DD.bam ]; then
	echo "Missing $BAMDIR/$SAMPLE.DD.bam - re-run step 1 with $N"
	exit
    fi
    if [ ! -e $BAMDIR/$SAMPLE.DD.bai ]; then
 	java -jar $PICARD BuildBamIndex I=$BAMDIR/$SAMPLE.DD.bam TMP_DIR=/scratch
    fi

    if [ ! -e $BAMDIR/$SAMPLE.intervals ]; then 
 	java -Xmx$MEM -jar $GATK \
   	    -T RealignerTargetCreator \
   	    -R $GENOMEIDX.fa \
   	    -I $BAMDIR/$SAMPLE.DD.bam \
   	    -o $BAMDIR/$SAMPLE.intervals
    fi
    
    if [ ! -e $BAMDIR/$SAMPLE.realign.bam ]; then
	java -Xmx$MEM -jar $GATK \
   	    -T IndelRealigner \
   	    -R $GENOMEIDX.fa \
   	    -I $BAMDIR/$SAMPLE.DD.bam \
   	    -targetIntervals $BAMDIR/$SAMPLE.intervals \
   	    -o $BAMDIR/$SAMPLE.realign.bam
    fi
    
    if [ ! -e $KNOWNSITES]; then
	if [ ! -f $BAMDIR/$SAMPLE.recal.grp ]; then
 	    java -Xmx$MEM -jar $GATK \
		-T BaseRecalibrator \
		-R $GENOMEIDX.fa \
		-I $BAMDIR/$SAMPLE.realign.bam \
		--knownSites $KNOWNSITES \
		-o $BAMDIR/$SAMPLE.recal.grp
	fi
	if [ ! -f $BAMDIR/$SAMPLE.recal.bam ]; then
 	    java -Xmx$MEM -jar $GATK \
		-T PrintReads \
		-R $GENOMEIDX.fa \
		-I $BAMDIR/$SAMPLE.realign.bam \
		-BQSR $BAMDIR/$SAMPLE.recal.grp \
		-o $BAMDIR/$SAMPLE.recal.bam
	fi
    fi
done
