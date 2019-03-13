#!/bin/sh

#PBS -N reduce_scratch
#PBS -q standby
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=4:00:00
#PBS -m abe

module purge
module load bioinfo

cd $PBS_O_WORKDIR

cat species_manu.txt | while read -r LINE

do

cd $LINE

# remove excess files
rm -v !("realigned_reads.bam"|"NO_QUAL_variants.g.vcf"|"realigned_reads.sample_cumulative_coverage_counts") 

rm -rf tmp

cd ..

done

# END
