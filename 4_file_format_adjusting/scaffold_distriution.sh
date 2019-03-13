#!/bin/sh

#PBS -N scaf_dist
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=1:00:00
#PBS -m abe

module purge
module load bioinfo
module load r

cd $PBS_O_WORKDIR

cat N50.txt | while read -r LINE

do

echo $LINE

cd $LINE

Rscript /scratch/snyder/a/abruenic/ROH_mammals_Sep_2017_WD/ROH_mammals_Sep_2017/N50/scaf_dist.R

# select line 2 from 

cd ..

done

#END
