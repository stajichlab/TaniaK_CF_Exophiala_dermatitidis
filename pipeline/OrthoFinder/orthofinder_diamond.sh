#!/usr/bin/bash -l
#SBATCH -p short -C xeon -N 1 -n 96 --mem 24gb --out logs/orthofinder.%A.log

mkdir -p logs
module load orthofinder
orthofinder -t 96 -a 96 -f orthofinder_run/longest_isoforms -S diamond_ultra_sens -o OrthoFinder_diamond2
