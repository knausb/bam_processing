#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N gatk_hc
#$ -o gatk_hcout
#$ -e gatk_hcerr
# #$ -l mem_free=2G
#$ -V
# #$ -q !(gbs|grungall1)
#$ -q !gbs
#$ -p -10
# #$ -h
# #$ -t 1-39:1
# #$ -t 1-7:1
# #$ -t 5-5:1
# #$ -t 1-10:1
#$ -t 11-4921

i=$(expr $SGE_TASK_ID - 1)

#PATH=~/bin/gatk/:$PATH

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"
GATK="~/bin/gatk/GenomeAnalysisTK.jar"

# Input file containing sample files.
#BAMS=( `cat "../bams4.txt" `)
#BAMS=( `cat "../bams3.txt" `)

# Parse semicolon delimited lines.
#IFS=';' read -a arr <<< "${BAMS[$i]}"

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date

echo
echo "Path:"
echo $PATH
echo

export _JAVA_OPTIONS="-XX:ParallelGCThreads=1"

# https://www.broadinstitute.org/gatk/guide/article?id=38

CMD="$JAVA -Xmx2g -Djava.io.tmpdir=/data/ \
     -jar $GATK \
     -T HaplotypeCaller \
     -R $REF \
     -L Supercontig_1.$SGE_TASK_ID \
     -I bams4.list \
     -o gatk_hc/sc_1.$SGE_TASK_ID.vcf"

echo $CMD
eval $CMD

date

# EOF.
