#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16G --time 24:00:00 --out logs/antismash.%a.log -J antismash

module unload miniconda2
module unload miniconda3
module load anaconda3
module load antismash/5.1.1
module load antismash/5.1.1
which perl
which antismash
hostname
#module list
#/opt/linux/centos/7.x/x86_64/pkgs/meme/4.11.2/bin/meme
#ldd /opt/linux/centos/7.x/x86_64/pkgs/meme/4.11.2/bin/meme
CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
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

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi

IFS=,
INPUTFOLDER=predict_results

cat $SAMPFILE | sed -n ${N}p | while read BASE SPECIES STRAIN PHYLUM BUSCO LOCUS
do
	name=$BASE

	if [ ! -d $OUTDIR/$name]; then
		echo "No annotation dir for ${name}"
		exit
 	fi
	echo "processing $OUTDIR/$name"
	if [[ ! -d $OUTDIR/$name/antismash_local && ! -s $OUTDIR/$name/antismash_local/index.html ]]; then
	#	antismash --taxon fungi --output-dir $OUTDIR/$name/antismash_local  --genefinding-tool none \
	#    --asf --fullhmmer --cassis --clusterhmmer --asf --cb-general --pfam2go --cb-subclusters --cb-knownclusters -c $CPU \
	#    $OUTDIR/$name/$INPUTFOLDER/*.gbk
	 time antismash --taxon fungi --output-dir $OUTDIR/$name/antismash_local \
	 --genefinding-tool none --fullhmmer --clusterhmmer --cb-general \
		 --pfam2go -c $CPU $OUTDIR/$name/$INPUTFOLDER/*.gbk
	fi
done
