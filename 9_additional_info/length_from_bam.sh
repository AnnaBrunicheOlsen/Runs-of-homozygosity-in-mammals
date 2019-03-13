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

# replace # in VCF SNP part 
sed -i -e 's/ID#/ID_/g' SNPs_20x_auto.vcf

# omit header
grep -v "#" SNPs_20x_auto.vcf > SNPs.txt

# grep gi_entries
cut -d. -f1 SNPs.txt > gi_numbers.txt

# count number of times each gi_ entry occurs
uniq -c gi_numbers.txt > gi_frequency.txt

# make list with scaffolds with 20 or more SNPs
awk ' $1 > 19 ' gi_frequency.txt > gi_ge_20.txt

# get gi numbers
sed -i -e 's/_ref/ ref/g' gi_ge_20.txt

awk '{ print $2 }' gi_ge_20.txt > gi.txt

# get scaffold lengths from bam file
samtools view -H realigned_reads.bam > header

grep -F -f gi.txt header > scaffolds.txt

sed -i -e 's/LN:/LN /g' scaffolds.txt

awk '{ print $4 }' scaffolds.txt > scaf_length.txt

scaf_length=$(awk '{ sum += $1 } END { print sum }' scaf_length.txt)

echo -e "$LINE\t $scaf_length" \
>> /scratch/snyder/a/abruenic/ROH_mammals_Sep_2017_WD/ROH_mammals_Sep_2017/ROH_mammals_manuscript_species/lengths_scaf.txt

cd ..

done


# END