#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16gb -J clinker --out clinker.%A.log -p batch

hostname
MEM=64
CPU=$SLURM_CPUS_ON_NODE

source activate clinker

clinker *.gbk -p plot_E_derm_ALL.html
