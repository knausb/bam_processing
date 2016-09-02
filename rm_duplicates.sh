#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N rmdup
#$ -o rmdupout
#$ -e rmduperr
# #$ -l mem_free=10G
#$ -V
# #$ -h
#$ -t 1-46:1

i=$(expr $SGE_TASK_ID - 1)

#PATH=~/bin/samtools-1.1:$PATH

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

FILE=( `cat "bams1.txt" `)
#IFS=';' read -a arr <<< "${FILE[$i]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date

echo
echo "Path:"
echo $PATH
echo

samtools --version

#CMD="samtools calmd -Erb bams/${FILE[$i]} $REF > calmd/${FILE[$i]}"
#echo $CMD
#eval $CMD

CMD="samtools rmdup calmd/${FILE[$i]} rmdup/${FILE[$i]}"
echo $CMD
eval $CMD

CMD="samtools index rmdup/${FILE[$i]}"
echo $CMD
eval $CMD

date
