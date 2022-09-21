#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/repeatMasker.log

module load RepeatMasker

RepeatMasker -s -pa 1 -species fungi -gff genomes/Ex4.new.fasta -dir genomes/
