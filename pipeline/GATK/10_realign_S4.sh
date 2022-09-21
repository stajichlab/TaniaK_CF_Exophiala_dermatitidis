#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH  --mem=32G
#SBATCH  --time=36:00:00
#SBATCH --job-name realign
#SBATCH --output=logs/realign.%a.log

module load java/8
module load gatk/3.7
module load picard

MEM=32g
if [ ! $CPU ]; then
    CPU=1
fi

java -Xmx$MEM -jar $GATK -T RealignerTargetCreator -R genome/Exophiala_dermatitidis_Ex4.fa -I aln/S4.DD.bam -o aln/S4.intervals --fix_misencoded_quality_scores -fixMisencodedQuals

#java -Xmx$MEM -jar $GATK -T IndelRealigner -R genome/Exophiala_dermatitidis_Ex4.fa -I aln/S4.DD.bam -targetIntervals aln/S4.intervals -o aln/S4.realign.bam
