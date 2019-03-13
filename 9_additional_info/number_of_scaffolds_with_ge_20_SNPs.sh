#!/bin/sh

#PBS -N proportion_snps
#PBS -q standby
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=4:00:00
#PBS -m abe

module purge
module load bioinfo

cd $PBS_O_WORKDIR

# Edits as suggested by two Evolutionary Applications reviewers
# Edits as suggested by two Conservations Genetics reviewers

# What proportion of the genome is in scaffolds containing 20 or more SNPs 
# for each species? 

cat species_manu.txt | while read -r LINE

do

cd $LINE

# omit header
grep -v "#" SNPs_20x_auto.vcf > SNPs.txt

# total SNPs
wc -l SNPs.txt 

# count heterozygotes
snps="$(wc -l < SNPs.txt)"

# grep gi_entries
cut -d. -f1 SNPs.txt > gi_numbers.txt

# count number of times each gi_ entry occurs
uniq -c gi_numbers.txt > gi_frequency.txt

# total number of different gi_
total_gi="$(wc -l < gi_frequency.txt)" 

# gi_ entries is equal or greater than 20
ge_20="$(awk '$1>19{c++} END{print c+0}' gi_frequency.txt)"

# write to file
# print to file
echo -e "$PWD\t $snps\t $total_gi\t $ge_20" \
>> /scratch/snyder/a/abruenic/ROH_mammals_Sep_2017_WD/ROH_mammals_Sep_2017/ROH_mammals_manuscript_species/proportion_scaffolds_20_snps.txt

cd ..

done

# END 
