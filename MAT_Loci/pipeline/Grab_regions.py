#python script to grab specific regions, which you will need to determine before hand.
python
from Bio import SeqIO
#index your gbk file as a dictionary
record_dict = SeqIO.index("GCA_000149865.1_BD_JEL423_genomic.gbk", "genbank")
#Check that it was indexed
print(record_dict)
#ID your chromosome of interest. This is the same as your contig ID
chrom1 = record_dict['DS022322.1']
#Find the specific start/stop you want to subset your gbk file. You can do this by ID'ing your gene start/stop for the region of interest using the gbk file. 
chrom1_subseq = chrom1[1:175284]
#write the output to a new gbk
SeqIO.write(chrom1_subseq, "DS022322_Polished.gbk", "gb")
