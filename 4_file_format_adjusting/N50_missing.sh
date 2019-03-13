#!/bin/sh

#PBS -N vcf
#PBS -q fnrquail
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo

cd $PBS_O_WORKDIR


# END