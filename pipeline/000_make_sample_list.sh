for n in $(ls fastq/*_1.fq.gz); do b=$(basename $n _1.fq.gz); m=$(ls fastq/${b}_2.fq.gz); echo "$b,$m,$n,Novogene"; done > samples.csv
