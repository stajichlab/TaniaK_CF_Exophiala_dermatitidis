#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 16gb -p short --out snpEff.run.log

module load snpEff

CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi


pushd snpEff
java -jar $SNPEFFJAR ann -download -i vcf \
    -c snpEff.config Exophiala_dermatitidis_nih_ut8656  \
    ../$VARIANTFOLDER/$PREFIX.selected_nofixed.SNP.vcf > $PREFIX.selected_nofixed.SNP.snpEff.vcf

