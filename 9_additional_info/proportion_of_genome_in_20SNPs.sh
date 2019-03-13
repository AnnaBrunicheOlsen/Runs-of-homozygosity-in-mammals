#!/bin/sh

#PBS -N proportion_snps
#PBS -q standby
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=4:00:00
#PBS -m abe

module purge
module load bioinfo
module load samtools

cd $PBS_O_WORKDIR


# estimate hetero
# number of sites how large a proportion of genome surveyed
# total length of scaffolds with 20 or more SNPs 

###################################
# scaffolds with 20 or more SNPs
###################################
# omit header
grep -v "#" SNPs_20x_auto.vcf > SNPs.txt

# count number of SNPs 
snps=$(wc -l < SNPs.txt)

# grep gi_entries
cut -d. -f1 SNPs.txt > gi_numbers.txt

# count number of times each gi_ entry occurs
uniq -c gi_numbers.txt > gi_frequency.txt

# total number of different gi_
total_gi="$(wc -l < gi_frequency.txt)" 

# gi_ entries is equal or greater than 20
ge_20="$(awk '$1>19{c++} END{print c+0}' gi_frequency.txt)"

# list unique gi with 20 or more SNPs
awk '$1>19' gi_frequency.txt > gis.txt

# sum the number of occurences == number of SNPs in scaffolds with 20 or more SNPs
SNPs20="$(awk '{s+=$1}END{print s}' gis.txt)"

# print to file
# header: current WD, total number of SNPs, number of SNPs in scaffolds >19SNPs, total number of scaffolds, scaffolds >19 SNPs
echo -e "$PWD\t $snps\t $SNPs20\t $total_gi\t $ge_20" \
>> /scratch/snyder/scaffolds_20_snps.txt

###################################
# heterozygosity in scaffolds >19SNPs
###################################



# count heterozygotes
grep '0/1' SNPs_20x_auto.vcf > het.txt
het="$(wc -l < het.txt)"

# count homozygotes
grep '0/0' SNPs_20x_auto.vcf > homo.txt
grep '1/1' SNPs_20x_auto.vcf >> homo.txt
homo="$(wc -l < homo.txt)"

# END 
