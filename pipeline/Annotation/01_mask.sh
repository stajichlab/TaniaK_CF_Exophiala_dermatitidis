#!/bin/bash
#SBATCH -p batch --time 1-0:00:00 --ntasks 8 --nodes 1 --mem 8G --out logs/mask.%a.log
# This script runs Funannotate mask step
# Because this a project focused on population genomics we are assuming the repeat library
# generated for one R.stolonifer is suitable for all to save time this is used
# This expects to be run as slurm array jobs where the number passed into the array corresponds
# to the line in the samples.info file

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

if [ -z $SLURM_JOB_ID ]; then
    SLURM_JOB_ID=$$
fi

INDIR=genomes
OUTDIR=genomes
SAMPLEFILE=strains.csv
N=${SLURM_ARRAY_TASK_ID}
RM_SPECIES=fungi
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/config)

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
IFS=,

tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read BASE SPECIES STRAIN PHYLUM BUSCO LOCUS
do
    IN=$(realpath $INDIR/$BASE.sorted.fasta)
    OUT=$(realpath $OUTDIR/$BASE.masked.fasta)

 if [ ! -f $IN ]; then
     echo "Cannot find $BASE.sorted.fasta in $INDIR - may not have been run yet"
     exit
 fi

 if [ ! -f $OUT ]; then
     
   #module load funannotate/git-live
    module load funannotate/1.8
    source activate funannotate-1.8
    module unload rmblastn
    module load ncbi-rmblast/2.6.0
    export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

    mkdir $BASE.mask.$SLURM_JOB_ID
    pushd $BASE.mask.$SLURM_JOB_ID
    funannotate mask --cpus $CPU -i $IN -o $OUT --repeatmasker_species $RM_SPECIES

    mv funannotate-mask.log ../logs/$BASE.funannotate-mask.log
    popd
    rmdir $BASE.mask.$SLURM_JOB_ID
 else 
     echo "Skipping ${BASE} as masked already"
 fi
done
