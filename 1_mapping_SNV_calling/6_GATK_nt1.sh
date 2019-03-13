#!/bin/sh

#PBS -N GATK_nt1
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo
module load GATK
module load vcflib

cd $PBS_O_WORKDIR

# select SNPs
GenomeAnalysisTK -T SelectVariants -R ref.fa -V NO_QUAL_variants.g.vcf \
-selectType SNP -o SNPs.vcf

# coverage needs to be included we chose 20x as minimum
vcffilter -f "DP > 20" SNPs.vcf

# END

