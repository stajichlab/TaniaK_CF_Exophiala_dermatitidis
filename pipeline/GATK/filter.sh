#!/usr/bin/bash
#SBATCH -p short --mem=16G --nodes 1 --ntasks 2 --out logs/filter_step2.log


module load bcftools

#SNP
#bcftools view -e 'GT="."' -O u -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED.vcf | bcftools view -i 'QUAL<1000' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' > snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_2step.vcf
#bcftools view -i 'QUAL>1000' -O u -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED.vcf | bcftools view -e 'GT="."' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' > snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_2step.vcf
#bcftools view -i 'FORMAT/DP>8' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_2step.vcf > snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_3step.vcf
#bcftools view -i 'FORMAT/DP<50' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_3step.vcf > snpEff_tryagain/Exophiala.Run1.snpEff_CLEANED_Filter_4step.vcf

#INDEL
#bcftools view -e 'GT="."' -O u -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' vcf/Exophiala.Run1.selected.INDEL.vcf | bcftools view -i 'QUAL<1000' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' > snpEff_final_v/Exophiala.Run1.selected.INDEL_Step1.vcf
bcftools view -i 'QUAL>1000' -O u -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_final_v/Exophiala.Run1.selected.INDEL.vcf | bcftools view -e 'GT="."' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' > snpEff_final_v/Exophiala.Run1.selected.INDEL_Step1.vcf
bcftools view -i 'FORMAT/DP>8' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_final_v/Exophiala.Run1.selected.INDEL_Step1.vcf > snpEff_final_v/Exophiala.Run1.selected.INDEL_Step2.vcf
bcftools view -i 'FORMAT/DP<50' -O v -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' snpEff_final_v/Exophiala.Run1.selected.INDEL_Step2.vcf > snpEff_final_v/Exophiala.Run1.selected.INDEL_Step3.vcf
