#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=16 --mem 80gb
#SBATCH --output=logs/annotfunc.%a.log
#SBATCH --time=3-0:00:00
#SBATCH -p intel -J annotfunc
module unload miniconda2
module unload miniconda3
#module load funannotate/development
module unload perl
module unload python
module load funannotate/1.8
#source activate funannotate-1.8
module load phobius
module load diamond/2.0.2
CPUS=$SLURM_CPUS_ON_NODE
OUTDIR=annotate
INDIR=genomes
SAMPFILE=strains.csv
BUSCO=eurotiomycetes_odb10
species="Exophiala dermatitidis"
if [ -z $CPUS ]; then
 CPUS=1
fi

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi
IFS=,
SPECIES="Exophiala_dermatitidis"
tail -n +2 $SAMPFILE | sed -n ${N}p | while read BASE SPECIES STRAIN PHYLUM BUSCO LOCUS
do
	name=$BASE
	Strain=$STRAIN
	MOREFEATURE=""
	TEMPLATE=$(realpath lib/Exophiala_dermatitidis.sbt)
	if [ ! -f $TEMPLATE ]; then
		echo "NO TEMPLATE for $name"
		exit
	fi
	ANTISMASHRESULT=$OUTDIR/$name/annotate_misc/antiSMASH.results.gbk
	echo "$name $species"
	if [[ ! -f $ANTISMASHRESULT && -d $OUTDIR/$name/antismash_local ]]; then
		ANTISMASH=$OUTDIR/$name/antismash_local/$name.gbk
		if [ ! -f $ANTISMASH ]; then
			echo "CANNOT FIND $ANTISMASH in $OUTDIR/$name/antismash_local"
		else
			rsync -a $ANTISMASH $ANTISMASHRESULT
		fi
	fi
	# need to add detect for antismash and then add that
	funannotate annotate --sbt $TEMPLATE --busco_db $BUSCO -i $OUTDIR/$name --species "$SPECIES" --strain "$Strain" --cpus $CPUS $MOREFEATURE $EXTRAANNOT --force
done
