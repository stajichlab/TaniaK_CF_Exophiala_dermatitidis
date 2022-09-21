#!/bin/bash
#SBATCH -p batch --time 3-0:00:00 --ntasks 24 --nodes 1 --mem 24gb --out logs/predict.%a.log

module unload miniconda2
module unload anaconda3
module unload perl
module unload python
module unload miniconda3
module load funannotate/1.8
module load workspace/scratch

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db

SEED_SPECIES="anidulans"
BUSCOPATH=/srv/projects/db/BUSCO/v10/lineages
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=$(realpath genomes)
OUTDIR=$(realpath annotate)
SEQCENTER=UCR
AUGUSTUSMODEL=exophiala_dermatitidis_ex4 # this is installed in $FUNANNOTATE_DB
mkdir -p $OUTDIR

SAMPLEFILE=strains.csv
N=${SLURM_ARRAY_TASK_ID}

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
    if [ ! -f $INDIR/$BASE.masked.fasta ]; then
	echo "No genome for $INDIR/$BASE.masked.fasta yet - run 01_mask.sh $N"
	exit
    fi
    if [ "$BASE" -ne "Exophiala_dermatitidis_Ex4" ]; then
	echo "skipping strain $STRAIN as expected a only Ex4 for this optimization"
	# this will generate a prediction only for Ex4
	exit
    fi
    # PEPLIB=$(realpath lib/informant.aa) if you want to specify your own peptide libary for extra evidence
    GENOMEFILE=$INDIR/$BASE.masked.fasta
    OUTDEST=$OUTDIR/$BASE
    # no need to run in a tempfolder as funannotate deals with this better but it 
    # 
    funannotate predict --cpus $CPU --keep_no_stops --SeqCenter $SEQCENTER \
	--optimize_augustus \	
	--busco_db $BUSCOPATH/$BUSCO   --tempdir $SCRATCH \
	-i $GENOMEFILE --name $LOCUS \
	--protein_evidence $FUNANNOTATE_DB/uniprot_sprot.fasta \
	--min_training_models 50 --AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
	-s "$SPECIES" --strain $STRAIN  -o $OUTDEST --busco_seed_species $SEED_SPECIES
done
