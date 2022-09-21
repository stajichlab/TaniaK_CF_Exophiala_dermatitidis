#!/usr/bin/bash
#SBATCH -p short  --mem 16gb -N 1 -n 8 --out logs/ragooo.%a.log

module unload miniconda3
module unload miniconda2
module load anaconda3
module load minimap2

which conda
source activate ragoo
conda activate ragoo

CPU=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
if [ -z $CPU ]; then
	CPU=1
fi
ASM=genomes
OUT=scaffolds
CTGS=$(ls $ASM/*.pilon.fasta | sed -n ${N}p)
NAME=$(basename $CTGS .sorted.fasta)
CTGS=$(realpath $CTGS)
REF=$(realpath genome_ref/GCF_000230625.1_Exop_derm_V1_genomic.fna)

echo $REF
echo $CTGS
SCAF=$OUT/$NAME

mkdir -p $SCAF
pushd $SCAF
ln -s $CTGS contigs.fasta
ln -s $REF reference.fasta
ragoo.py -m $(which minimap2) -t $CPU -b -C contigs.fasta reference.fasta
module load AAFTF
AAFTF assess -i ragoo_output/ragoo.fasta -r assembly.stats.txt
popd
