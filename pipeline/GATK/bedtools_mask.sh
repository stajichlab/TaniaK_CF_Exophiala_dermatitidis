#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH  --mem=32G
#SBATCH  --time=36:00:00
#SBATCH --job=bedtools
#SBATCH --output=logs/bedtools.%a.log

module load bedtools

bedtools intersect -a Ex4.new.fasta.out.gff -b Exophiala.Run2.selected.INDEL.vcf.gz -v > Exophiala.Run2.selected.INDEL_CLEANED.vcf.gz 
