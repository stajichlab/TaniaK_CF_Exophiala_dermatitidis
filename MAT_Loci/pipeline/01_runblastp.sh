#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/blastp_%a.log

module load ncbi-blast

# EXPECTED VARIABLES
GENOMEFOLDER=pep
BLASTP=blastp
mkdir -p $BLASTP
SAMPLES=strains.csv

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then 
    echo "Need a number via slurm --array or cmdline"
    exit
 fi
fi

IFS=,
sed -n ${N}p $SAMPLES | while read STRAIN 
do
	blastp -db $GENOMEFOLDER/$STRAIN -query SLA.faa -evalue 1e-5  -outfmt 6 -out $BLASTP/$STRAIN.SLA2.tab
done
