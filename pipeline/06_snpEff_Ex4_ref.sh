#!/usr/bin/bash
#SBATCH -p short --mem=16G --nodes 1 --ntasks 2 --out logs/snpEff_ex4_ref.log

module load snpEff
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

if [ -z $FINALVCF ]; then
	echo "need a FINALVCF variable in config.txt"
	exit
fi

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
pushd $SNPEFFOUT
COMBVCF="../$FINALVCF/$PREFIX.selected.SNP.vcf.gz ../$FINALVCF/$PREFIX.selected.INDEL.vcf.gz"
#COMBVCF="../$FINALVCF/$PREFIX.selected.SNP.vcf.gz ../$FINALVCF/$PREFIX.selected.INDEL.vcf.gz"
for n in $COMBVCF
do
 echo $n
 st=$(echo $n | perl -p -e 's/\.gz//')
 if [ ! -f $n ]; then
	 bgzip $st
	 tabix $n
 fi
done
INVCF=$PREFIX.comb_selected.SNP.vcf
OUTVCF=$PREFIX.snpEff_CLEANED.vcf
OUTTAB=$PREFIX.snpEff_CLEANED.tab
OUTTAB2=$PREFIX.snpEff_CLEANED2.vcf
OUTNEW=$PREFIX.snpEff_CLEANED_Filtered.vcf
OUT_DEPTH=$PREFIX.snpEff_CLEANED_DP.tab
bcftools concat -a -d both -o $INVCF -O v $COMBVCF
java -Xmx$MEM -jar $SNPEFFJAR eff -dataDir `pwd`/data -v $SNPEFFGENOME $INVCF > $OUTVCF

bcftools query -e 'GT="."' -i 'QUAL<1000' -H -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' $OUTVCF > $OUTTAB
bcftools query -e 'GT="."' -i 'QUAL<1000' -H -f '%CHROM %POS\t[\t%DP]\n' $OUTVCF > $OUT_DEPTH
bcftools query -e 'GT="."' -i 'QUAL<1000' -H -f '%CHROM\t%POS\t%QUAL\t%FILTER\t%REF\t%ALT{0}[\t%TGT]\tADs:[ %AD]\t DPs:[ %DP]\t%INFO/ANN\n' $OUTVCF -Ou v > $OUTTAB2
#bcftools annotate -x 'GT="."' -i 'QUAL<1000' -h -o $OUTTAB2 -O v
#bcftools view -e 'GT="."' -i 'QUAL<1000' -h 
 
# requires you to have run Pfam on the proteome and follow the format from FungiDB or to rewrite the python script below
#../scripts/map_snpEff2domains.py --vcf $OUTVCF --domains ../genome/FungiDB-39_AfumigatusAf293_InterproDomains.txt --output A_fumigiatus_Af293.Popgen8.snpEf.domain_variants.tsv
#python ../scripts/snpEff_2_tab.py $PREFIX.snpEff.vcf >$PREFIX.snpEff.matrix.tab
#last line wasn't working with the script. I ran it separately. Run conda activate pyvcf then the above script.
