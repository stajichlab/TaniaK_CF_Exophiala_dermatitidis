#!/usr/bin/bash 

#SBATCH --nodes 1 --ntasks 8 --mem 24G --out logs/validate.%A.log --time 2:00:00 -p short

#This script takes a reference genome and a tab delimited sample list of: sample name\tsample_reads_1.fq\tsample_reads_2.fq.
# For each line defined by the number in an array job, this script will align set of reads to a reference genome using bwa mem.
#After, it uses picard to add read groups and mark duplicates. 

RGCENTER=UCR
RGPLATFORM=Illumina
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

picard ValidateSamFile I=aln/S4.DD.bam IGNORE_WARNINGS=true MODE=VERBOSE
