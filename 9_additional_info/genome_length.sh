#!/bin/sh

#PBS -N genome_sra
#PBS -q standby
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=4:00:00
#PBS -m abe

module purge
module load bioinfo
module load samtools

cd $PBS_O_WORKDIR

cat species_manu.txt | while read -r LINE

do

cd $LINE

# get scaffold lengths from bam file
samtools view -H realigned_reads.bam > header

sed -i -e 's/LN:/LN /g' header

awk '{ print $4 }' header > genome_length.txt

genome_length=$(awk '{ sum += $1 } END { print sum }' genome_length.txt)

echo -e "$LINE\t $genome_length" \
>> /scratch/snyder/a/abruenic/ROH_mammals_Sep_2017_WD/ROH_mammals_Sep_2017/ROH_mammals_manuscript_species/genome_length.txt

cd ..

done

# END