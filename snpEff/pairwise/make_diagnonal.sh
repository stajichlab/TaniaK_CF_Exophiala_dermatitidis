#!/usr/bin/bash -l
module load plink

plink --allow-extra-chr --vcf Exophiala.Run1.selected_nofixed.SNP_CLEANING_Filter4step.vcf --genome full --out SNP
awk 'BEGIN{OFS="\t"} {print $1,$3,$15+$16}' SNP.genome > SNP.pairwise.tsv

plink --allow-extra-chr --vcf Exophiala.Run1.selected.INDEL_Step3.vcf --genome full --out INDEL
awk 'BEGIN{OFS="\t"} {print $1,$3,$15+$16}' INDEL.genome > INDEL.pairwise.tsv

