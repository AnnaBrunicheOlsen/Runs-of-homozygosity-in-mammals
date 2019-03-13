#!/bin/sh

#PBS -N vcf
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo
module load samtools

cd $PBS_O_WORKDIR

cat N50.txt | while read -r LINE

do

echo $LINE

cd $LINE

samtools faidx ref.fa

cd ..

done



#END
