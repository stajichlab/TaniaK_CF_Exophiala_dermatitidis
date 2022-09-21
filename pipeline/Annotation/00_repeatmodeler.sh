#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G --time 2-00:00:00  --out logs/repeatModeler.log

module load RepeatModeler

RepeatModeler -database Ex4.* -engine ncbi  genomes/Ex4.new.fasta
