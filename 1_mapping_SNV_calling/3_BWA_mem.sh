#!/bin/sh

#PBS -N BWA_mem
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=20,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo
module load bwa

cd $PBS_O_WORKDIR

# fastq
bwa mem -t 20 -M -R "@RG\tID:group1\tSM:sample1\tPL:illumina\tLB:lib1\tPU:unit1" ref.fa SRR393867_1.fastq.gz SRR393867_2.fastq.gz > SRR393867.sam

# truncated
#bwa mem -t 20 -M -R "@RG\tID:group1\tSM:sample1\tPL:illumina\tLB:lib1\tPU:unit1" ref.fa SRR387341_1.truncated.gz SRR387341_2.truncated.gz > SRR387341.sam


# END
