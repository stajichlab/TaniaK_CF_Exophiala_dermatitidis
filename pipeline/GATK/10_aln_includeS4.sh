#!/usr/bin/bash 

#SBATCH --nodes 1 --ntasks 8 --mem 24G --out logs/aln.S4.%a.log --time 2:00:00 -p short

#This script takes a reference genome and a tab delimited sample list of: sample name\tsample_reads_1.fq\tsample_reads_2.fq.
# For each line defined by the number in an array job, this script will align set of reads to a reference genome using bwa mem.
#After, it uses picard to add read groups and mark duplicates. 

CONFIG=config.txt
BWA=bwa
if [ -f $CONFIG ]; then
    source $CONFIG
fi

TEMPDIR=/scratch

module load bwa/0.7.17
module load picard
module load samtools/1.8
module unload java
module load java/8

CPU=1

hostname

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

bwa mem -M -t $CPU -x ont2d genome/Exophiala_dermatitidis_Ex4 fastq/E.derm.S4.fastq.gz  | samtools sort -T /scratch/S4 --reference Exophiala_dermatitidis_Ex4.fa -@ 24 -o aln/S4.sort.bam

picard AddOrReplaceReadGroups RGID=S4 RGSM=S4 RGLB=$PU RGPL=$RGPLATFORM RGPU=$PU RGCN=$CTR I=aln/S4.sort.bam O=aln/S4.sort.bam VALIDATION_STRINGENCY=SILENT

picard MarkDuplicates I=aln/S4.sort.bam O=$ALNFOLDER/S4.DD.bam METRICS_FILE=aln/S4.dedup.metrics VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true
