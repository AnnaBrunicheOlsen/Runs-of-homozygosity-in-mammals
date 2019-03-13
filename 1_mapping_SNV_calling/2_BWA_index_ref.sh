#!/bin/sh

#PBS -N BWA_index_ref
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo
module load bwa
module load fastqc

cd $PBS_O_WORKDIR

# index reference and map reads
bwa index -a bwtsw ref.fa

# END
