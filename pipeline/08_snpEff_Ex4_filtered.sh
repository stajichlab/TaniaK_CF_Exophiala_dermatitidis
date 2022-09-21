#!/usr/bin/bash
#SBATCH -p short --mem=16G --nodes 1 --ntasks 2 --out logs/snpEff_ex4_ref.%A.log

#module load snpEff
module load snpEff/4.3t
#module load snpEff/4.3P
module load bcftools/1.10
module load tabix
#conda activate pyvcf 

SNPEFFOUT=snpEff_tryagain
SNPEFFGENOME=Exophiala_dermatitidis_Ex4
snpEffConfig=snpEff.config
#GFFGENOME=Exophiala_dermatitidis_Ex4.gff
# note you were missing gff3 in the file name
GFFGENOME=Exophiala_dermatitidis_Ex4.gff3
MEM=16g

# this module defines SNPEFFJAR and SNPEFFDIR
if [ -f config.txt ]; then
	source config.txt
fi
GFFGENOMEFILE=$(realpath $GENOMEFOLDER/$GFFGENOME)
FASTAGENOMEFILE=$(realpath $GENOMEFOLDER/$GENOMEFASTA)
if [ -z $SNPEFFJAR ]; then
 echo "need to define \$SNPEFFJAR in module or config.txt"
 exit
fi
if [ -z $SNPEFFDIR ]; then
 echo "need to defined \$SNPEFFDIR in module or config.txt"
 exit
fi
# could make this a config

mkdir -p $SNPEFFOUT
if [ ! -e $SNPEFFOUT/$snpEffConfig ]; then
	rsync -a $SNPEFFDIR/snpEff.config $SNPEFFOUT/$snpEffConfig
	echo "# Exophiala_dermatitidis_Ex4 " >> $SNPEFFOUT/$snpEffConfig
  	echo "$SNPEFFGENOME.genome : Exophiala dermatitidis Ex4" >> $SNPEFFOUT/$snpEffConfig
#	chroms=$(grep '##sequence-region' $GFFGENOMEFILE | awk '{print $2}' | perl -p -e 's/\n/, /' | perl -p -e 's/,\s+$/\n/')
# generate chromosome names from the genome FASTA
  chroms=$(grep "^>" $GFFGENOMEFILE | perl -p -e 's/>(\S+)\s+/$1, /')
	echo -e "\t$SNPEFFGENOME.chromosomes: $chroms" >> $SNPEFFOUT/$snpEffConfig
	#echo -e "\t$SNPEFFGENOME.mito_A_fumigatus_Af293.codonTable : Mold_Mitochondrial" >> $SNPEFFOUT/$snpEffConfig
	mkdir -p $SNPEFFOUT/data/$SNPEFFGENOME
	gzip -c $GFFGENOMEFILE > $SNPEFFOUT/data/$SNPEFFGENOME/genes.gff.gz
	rsync -aL $REFGENOME $SNPEFFOUT/data/$SNPEFFGENOME/sequences.fa
	java -Xmx$MEM -jar $SNPEFFJAR build -datadir `pwd`/$SNPEFFOUT/data -c $SNPEFFOUT/$snpEffConfig -gff3 -v $SNPEFFGENOME
fi


java -Xmx$MEM -jar $SNPEFFJAR eff -dataDir `pwd`/data -v $SNPEFFGENOME $SNPEFFOUT/Exophiala.Run1.selected_nofixed.SNP_CLEANING_Filter4step.vcf > $SNPEFFOUT/Exophiala.Run1.selected_nofixed.SNP_Filtered_CLEANED4step_out.vcf
 
#python ../scripts/snpEff_2_tab.py Exophiala.Run1.selected_nofixed.SNP_Filtered_CLEANED4step_out.vcf >Exophiala.Run1.selected_nofixed.SNP_Filtered_CLEANED4step_out.tab
#last line wasn't working with the script. I ran it separately. Run conda activate pyvcf then the above script.
