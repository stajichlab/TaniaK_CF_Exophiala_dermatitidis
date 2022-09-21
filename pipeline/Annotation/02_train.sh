#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem 196gb -p intel,batch
#SBATCH --time=3-00:15:00
#SBATCH --output=logs/train.%a.log
#SBATCH --job-name="TrainFun"

# Define program name
# Load software
module load funannotate/1.8
MEM=196G

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
# Set some vars
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASACONF=$HOME/pasa.config.txt
export PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
export TRINITY=$(realpath `which Trinity`)
export TRINITYHOMEPATH=$(dirname $TRINITY)

# Determine CPUS
if [[ -z ${SLURM_CPUS_ON_NODE} ]]; then
    CPUS=1
else
    CPUS=${SLURM_CPUS_ON_NODE}
fi


N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
ODIR=annotate
INDIR=genomes
RNAFOLDER=lib/RNASeq

SAMPLEFILE=strains.csv
IFS=,
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read BASE SPECIES STRAIN PHYLUM BUSCO LOCUSTAG
do
    echo "SPECIES is $SPECIES"
    SPECIESNOSPACE=$(echo -n "$SPECIES" | perl -p -e 's/\s+/_/g')
    # Tania - I changed this to use the SPECIES
    if [[ ! -d $RNAFOLDER/$SPECIESNOSPACE || ! -f $RNAFOLDER/$SPECIESNOSPACE/Forward.fq.gz ]]; then
	     echo "For training step Need RNASeq files in folder  $RNAFOLDER/$SPECIESNOSPACE as  $RNAFOLDER/$SPECIESNOSPACE/Forward.fq.gz and  $RNASEQ/$SPECIESNOSPACE/Reverse.fq.gz"
	     exit
    fi
    #BASE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
    echo "sample is $BASE"
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    if [ ! -f $MASKED ]; then
	     echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
       exit
    fi
    
    echo $ODIR/$BASE/training
    mkdir -p $ODIR/$BASE/training
    if [ ! -d $ODIR/$BASE/training/normalize ]; then
	mkdir -p $ODIR/$BASE/training/normalize
	ln -s $RNAFOLDER/$SPECIESNOSPACE/trinity_run/normalize/* $ODIR/$BASE/training/normalize/
    fi
    if [ ! -d $ODIR/$BASE/training/trimmomatic ]; then
    	mkdir -p $ODIR/$BASE/training/trimmomatic
	ln -s $RNAFOLDER/$SPECIESNOSPACE/trinity_run/trimmomatic/* $ODIR/$BASE/training/trimmomatic/
    fi

    funannotate train -i $MASKED -o $ODIR/$BASE \
   	--jaccard_clip --species "$SPECIES" --isolate $STRAIN \
  	--cpus $CPUS --memory $MEM \
  	--left $RNAFOLDER/$SPECIESNOSPACE/Forward.fq.gz --right $RNAFOLDER/$SPECIESNOSPACE/Reverse.fq.gz
done
