#!/bin/bash
#SBATCH -p batch --time 2-0:00:00 --ntasks 16 --nodes 1 --mem 24G --out logs/update.%a.log

module unload perl
module unload miniconda2
module unload miniconda3
module load anaconda3
module unload perl
module unload python
module load funannotate/1.8

#PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
#TRINITYHOMEPATH=$(dirname `which Trinity`)

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
MEM=64G
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

INDIR=genomes
OUTDIR=annotate
SAMPFILE=strains.csv

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`
if [ -z "$MAX" ]; then
    MAX=0
fi
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASACONF=$HOME/pasa.config.txt
SBT=$(realpath lib/Exophiala_dermatitidis.sbt) # this can be changed
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read BASE SPECIES STRAIN PHYLUM BUSCO LOCUS
do
	#  if you want to use sqlite remove the mysql
	#  funannotate update --cpus $CPU -i $OUTDIR/$BASE --out $OUTDIR/$BASE --sbt $SBT --memory $MEM
	# --trinity $OUTDIR/$BASE/training/trinity.fasta
	echo "input file is  $OUTDIR/$BASE/predict_results/*.gbk"
  funannotate update --cpus $CPU -i $OUTDIR/$BASE --out $OUTDIR/$BASE --sbt $SBT --memory $MEM --trinity $OUTDIR/$BASE/training/trinity.fasta
done
