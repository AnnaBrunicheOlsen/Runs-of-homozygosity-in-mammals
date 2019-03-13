#!/bin/sh

#PBS -N vcf_list
#PBS -q standby
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=4:00:00
#PBS -m abe

module purge
module load bioinfo

cd $PBS_O_WORKDIR

# list with species we want SRA codes for
cat species_manu.txt | while read -r LINE

do

echo $LINE

cd $LINE

# for each species copy the vcf file used in the manu to folder
cp SNPs_20x_auto.vcf $LINE.vcf

mv $LINE.vcf /scratch/snyder/a/abruenic/SI

cd ..

done

# END
