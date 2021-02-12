#!/usr/bin/bash

#SBATCH -J snpEff --out snpEff.log --mem 8G --nodes 1 --ntasks 1 --time 2:00:00 -p short

module load snpEff

CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
else
        echo "Expected a config file $CONFIG"
        exit
fi
OUT=$FINALVCF/$PREFIX.selected.SNP.vcf


snpEffConfig=/bigdata/stajichlab/shared/projects/Candida/Candida_lusitaniae/lib/snpEff/snpEff.config
GENOME=C_lusitaniae
INVCF=$OUT
OUTVCF=$FINALVCF/$PREFIX.selected.SNP.snpeff.vcf


java -Xmx16g -jar $SNPEFFJAR eff -v -c $snpEffConfig $GENOME $INVCF > $OUTVCF
