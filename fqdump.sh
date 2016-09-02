#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N fqdmp
#$ -o fqdmp_out
#$ -e fqdmp_err
# #$ -l mem_free=2G
#$ -V
#$ -q !gbs
#$ -t 1-5:1

echo "SGE_TASK_ID: "
echo $SGE_TASK_ID
echo -n "Running on: "
hostname
echo
echo "Path:"
echo $PATH
echo

i=$(expr $SGE_TASK_ID - 1)

FQDUMP="/home/bpp/knausb/bin/sratoolkit.2.3.0-centos_linux64/bin/fastq-dump"

FILES=( `ls "*.sra" `)

date
echo

CMD="$FQDUMP --gzip --split-files $FILES[$i]"

echo $CMD
# eval $CMD

date
echo

# EOF.
