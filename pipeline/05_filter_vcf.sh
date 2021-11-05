#!/usr/bin/bash
#SBATCH --nodes 1 -p short
#SBATCH --ntasks 1
#SBATCH --mem 16G
#SBATCH --job-name=GATK.select_filter
#SBATCH --output=logs/GATK.select_filter.%a.log

module load gatk/4.0.8.1 
module unload java
module load java/8
hostname

CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi
GENOME=$GENOMEFOLDER/$GENOMEFASTA
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

if [ -z $VARIANTFOLDER ]; then
	echo "Need VARIANTFOLDER for output"
	exit
fi
for INFILE in $VARIANTFOLDER/*.Run?.vcf
do
    PREFIX=$(basename $INFILE .vcf)
    echo $PREFIX
    INSNP=$VARIANTFOLDER/$PREFIX.SNP.vcf
    ININDEL=$VARIANTFOLDER/$PREFIX.INDEL.vcf
    FILTEREDSNP=$VARIANTFOLDER/$PREFIX.filtered.SNP.vcf
    FILTEREDINDEL=$VARIANTFOLDER/$PREFIX.filtered.INDEL.vcf
    SNPONLY=$VARIANTFOLDER/$PREFIX.selected.SNP.vcf
    INDELONLY=$VARIANTFOLDER/$PREFIX.selected.INDEL.vcf

    FILTEREDFIXEDSNP=$VARIANTFOLDER/$PREFIX.filteredfixed.SNP.vcf
    FILTEREDFIXEDINDEL=$VARIANTFOLDER/$PREFIX.filteredfixed.INDEL.vcf
    SNPNOFIXED=$VARIANTFOLDER/$PREFIX.selected_nofixed.SNP.vcf
    INDELNOFIXED=$VARIANTFOLDER/$PREFIX.selected_nofixed.INDEL.vcf


 if [ ! -f $INSNP ]; then
  gatk SelectVariants \
  -R $GENOME \
  --variant $INFILE \
  -O $INSNP \
  --restrict-alleles-to BIALLELIC \
  --select-type-to-include SNP
 fi
 if [ ! -f $ININDEL ]; then
  gatk SelectVariants \
  -R $GENOME \
  --variant $INFILE \
  --output $ININDEL \
  --select-type-to-include INDEL --select-type-to-include MIXED --select-type-to-include MNP
 fi

 if [ ! -f $FILTEREDSNP ]; then
   gatk VariantFiltration --output $FILTEREDSNP \
   --variant $INSNP -R $GENOME \
   --cluster-window-size 10  \
   --filter-expression "QD < 2.0" --filter-name QualByDepth \
   --filter-expression "MQ < 40.0" --filter-name MapQual \
   --filter-expression "QUAL > 10" --filter-name QScore \
   --filter-expression "MQRankSum < -12.5" --filter-name MapQualityRankSum \
   --filter-expression "SOR > 3.0" --filter-name StrandOddsRatio \
   --filter-expression "FS > 60.0" --filter-name FisherStrandBias \
   --filter-expression "ReadPosRankSum < -8.0" --filter-name ReadPosRank \
   --missing-values-evaluate-as-failing
 fi

 if [ ! -f $FILTEREDFIXEDSNP ]; then
   gatk VariantFiltration --output $FILTEREDFIXEDSNP \
   --variant $INSNP -R $GENOME \
   --cluster-window-size 10  \
   --filter-expression "AF > 0.99" --filter-name FixedAllele \
   --filter-expression "QD < 2.0" --filter-name QualByDepth \
   --filter-expression "MQ < 40.0" --filter-name MapQual \
   --filter-expression "QUAL > 10" --filter-name QScore \
   --filter-expression "MQRankSum < -12.5" --filter-name MapQualityRankSum \
   --filter-expression "SOR > 3.0" --filter-name StrandOddsRatio \
   --filter-expression "FS > 60.0" --filter-name FisherStrandBias \
   --filter-expression "ReadPosRankSum < -8.0" --filter-name ReadPosRank \
   --missing-values-evaluate-as-failing

 fi
 if [ ! -f $FILTEREDINDEL ]; then
  gatk VariantFiltration --output $FILTEREDINDEL \
  --variant $ININDEL -R $GENOME \
  --cluster-window-size 10  -filter "QD < 2.0" --filter-name QualByDepth \
  -filter "MQRankSum < -12.5" --filter-name MapQualityRankSum \
  -filter "SOR > 4.0" --filter-name StrandOddsRatio \
  -filter "FS > 200.0" --filter-name FisherStrandBias \
  -filter "InbreedingCoeff < -0.8" --filter-name InbreedCoef \
  -filter "ReadPosRankSum < -20.0" --filter-name ReadPosRank 
 fi

 if [ ! -f $FILTEREDFIXEDINDEL ]; then
  gatk VariantFiltration --output $FILTEREDFIXEDINDEL \
  --variant $ININDEL -R $GENOME \
   --filter-expression "AF > 0.99" --filter-name FixedAllele \
  --cluster-window-size 10  -filter "QD < 2.0" --filter-name QualByDepth \
  -filter "MQRankSum < -12.5" --filter-name MapQualityRankSum \
  -filter "SOR > 4.0" --filter-name StrandOddsRatio \
  -filter "FS > 200.0" --filter-name FisherStrandBias \
  -filter "InbreedingCoeff < -0.8" --filter-name InbreedCoef \
  -filter "ReadPosRankSum < -20.0" --filter-name ReadPosRank 
 fi

 if [ ! -f $SNPONLY ]; then
   gatk SelectVariants -R $GENOME \
   --variant $FILTEREDSNP \
   --output $SNPONLY \
   --exclude-filtered
 fi

 if [ ! -f $INDELONLY ]; then
   gatk SelectVariants -R $GENOME \
   --variant $FILTEREDINDEL \
   --output $INDELONLY \
   --exclude-filtered 
 fi

 if [ ! -f $SNPNOFIXED ]; then
     gatk SelectVariants -R $GENOME \
	 --variant $FILTEREDFIXEDSNP \
	 --output $SNPNOFIXED \
	 --exclude-filtered
 fi

 if [ ! -f $INDELNOFIXED ]; then
     gatk SelectVariants -R $GENOME \
	 --variant $FILTEREDFIXEDINDEL \
	 --output $INDELNOFIXED \
	 --exclude-filtered

 fi
done
