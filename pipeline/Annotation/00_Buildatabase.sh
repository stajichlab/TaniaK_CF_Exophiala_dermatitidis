#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/repeatMasker.log

module load RepeatModeler

BuildDatabase -engine ncbi -name Ex4 Ex4.new.fasta

