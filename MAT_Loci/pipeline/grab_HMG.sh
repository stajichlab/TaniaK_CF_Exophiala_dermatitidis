#!/bin/bash

module load ncbi-blast/2.2.30+

filename=$1
while read line; do # reading each line
	blastdbcmd -entry $line -db pep/all >> HMG_Fasta/$line.aa.fa
done < $filename
