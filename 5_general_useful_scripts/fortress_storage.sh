#!/bin/bash

#PBS -N fortress
#PBS -q fnrdewoody
#PBS -l nodes=1:ppn=1,naccesspolicy=shared
#PBS -l walltime=300:00:00
#PBS -m abe
#PBS -M abruenic@purdue.edu

#set working directory
wd="/scratch/snyder/a/abruenic/ROH_mammals/ROH_mammals_Sep_2017/ROH_mammals_manuscript_species/"
cd $wd

#set name for compressed/archived directory
dname="ROH_mammals_project_files_2018"

#set path for archiving - lab
alpath="/group/fnrdewoody/ROH_mammal/"

#make a list of current directories
find -maxdepth 1 -mindepth 1 -type d -printf '%f\n' > directories.txt

#make temporary directory
mkdir temporary

#tar/compress all directories and put them into the temporary directory
cat directories.txt | while read -r LINE
	do
	name=$(echo $LINE | awk '{print $1}')
	tar -cjf  $name.tar $name
	mv $name.tar temporary/$name.tar
done

#copy to christie lab space on fortress
hsi put $wd$dname.tar : $alpath$dname.tar

#clean up backup from scratch space
#rm steelhead_mykiss_backup_$currdate.tar
#rm directories.txt
#/bin/rm -r temporary
