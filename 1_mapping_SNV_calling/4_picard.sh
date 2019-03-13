#!/bin/sh

#PBS -N picard
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe

module purge
module load bioinfo
module load samtools
module load picard-tools

cd $PBS_O_WORKDIR

# remove old tmp including files
rm -rf tmp

# make tmp directory for the files
mkdir tmp

# validate the SAM file should produce a validate_output.txt file that says there are no errors.
# samtools view -h -o aln.sam out.bam 
# one section for each SRA is needed. 
# Easiest to copy/paste and use find/replace to insert SRA numbers.
PicardCommandLine ValidateSamFile I=SRR387341.sam MODE=SUMMARY O=SRR387341_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387341.sam OUTPUT=SRR387341.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387342.sam MODE=SUMMARY O=SRR387342_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387342.sam OUTPUT=SRR387342.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387343.sam MODE=SUMMARY O=SRR387343_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387343.sam OUTPUT=SRR387343.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387344.sam MODE=SUMMARY O=SRR387344_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387344.sam OUTPUT=SRR387344.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387345.sam MODE=SUMMARY O=SRR387345_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387345.sam OUTPUT=SRR387345.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387346.sam MODE=SUMMARY O=SRR387346_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387346.sam OUTPUT=SRR387346.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387347.sam MODE=SUMMARY O=SRR387347_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387347.sam OUTPUT=SRR387347.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387348.sam MODE=SUMMARY O=SRR387348_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387348.sam OUTPUT=SRR387348.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387349.sam MODE=SUMMARY O=SRR387349_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387349.sam OUTPUT=SRR387349.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387350.sam MODE=SUMMARY O=SRR387350_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387350.sam OUTPUT=SRR387350.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387351.sam MODE=SUMMARY O=SRR387351_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387351.sam OUTPUT=SRR387351.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT

PicardCommandLine ValidateSamFile I=SRR387352.sam MODE=SUMMARY O=SRR387352_samfile.txt
PicardCommandLine SortSam SORT_ORDER=coordinate INPUT=SRR387352.sam OUTPUT=SRR387352.bam \
TMP_DIR=`pwd`/tmp VALIDATION_STRINGENCY=LENIENT


# merge bams
# list your SRA numbers in order to merge all bam files into one bam file.
samtools merge out.bam \
SRR359260.bam \
SRR359261.bam \
SRR359262.bam \
SRR359263.bam \
SRR360794.bam \
SRR360795.bam \
SRR360796.bam \
SRR360797.bam \
SRR387338.bam \
SRR387339.bam \
SRR387340.bam \
SRR387341.bam \
SRR387342.bam \
SRR387343.bam \
SRR387344.bam \
SRR387345.bam \
SRR387346.bam \
SRR387347.bam \
SRR387348.bam \
SRR387349.bam \
SRR387350.bam \
SRR387351.bam \
SRR387352.bam

# marking PCR duplicated reads without removing them
PicardCommandLine MarkDuplicates INPUT=out.bam OUTPUT=marked.bam M=metrics.txt

# check coverage
PicardCommandLine CollectWgsMetrics I=marked.bam O=coverage_marked.txt R=ref.fa 

PicardCommandLine BuildBamIndex INPUT=marked.bam

# create reference that reads can be mapped to. Will produce .fai file
samtools faidx ref.fa

PicardCommandLine CreateSequenceDictionary reference=ref.fa output=ref.dict

# END
