#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N align
#$ -e align0err
#$ -o align0out
#$ -q !gbs
# #$ -l mem_free=10G
#$ -V
# #$ -h
#$ -t 1-5:1

i=$(expr $SGE_TASK_ID - 1)

TEMPDIR="/data/"

echo "PATH:"
echo $PATH
echo

##### ##### ##### ##### #####
# Software

# https://gatk.broadinstitute.org/hc/en-us/articles/360037427071-CombineGVCFs
# https://gatk.broadinstitute.org/hc/en-us/articles/360037057852-GenotypeGVCFs

GATK="~/bin/gatk4/gatk-4.1.4.1/gatk"

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"


##### ##### ##### ##### #####
# User provided materials

# GATK reference
GREF="gatkref/Pr-102_v3.1.fasta"

# The file samples.txt contains info about sample names and files.
# Each line is one sample and one job.
# The line is a semi colon delimited list.
# The first element is the sample name.
# The second element is the fastq file including any path info.
#
# t30-4;../fastqs/ATCGGC.fastq.gz
#

#FILE=( `cat "samples_se.txt" `)
FILE=( `cat "samples_pe2.txt" `)
IFS=';' read -a arr <<< "${FILE[$i]}"
echo "${arr[1]}"


##### ##### ##### ##### #####
# Report what we ended up with

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch
startEpoch=$myEpoch

echo "GATK info"
CMD="$GATK --version"
echo $CMD
eval $CMD
echo

# Java version.
echo "java info"
CMD="$JAVA -version 2>&1"
echo $CMD
eval $CMD
echo



##### ##### ##### ##### #####
# Combine g.vcf files.

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\ CombineGVCFs \
   -R $GREF \
   --variant sample1.g.vcf.gz \
   --variant sample2.g.vcf.gz \
   --TMP_DIR /data/ \
   -O cohort.g.vcf.gz"

echo $CMD
#eval $CMD



##### ##### ##### ##### #####
# Create gvcf

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\" HaplotypeCaller \
   -R $GREF \
   -I $TEMPDIR${arr[0]}_dupmrk.bam \
   -O $TEMPDIR${arr[0]}.g.vcf.gz \
   -ERC GVCF"

echo $CMD
#eval $CMD

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch

date

##### ##### ##### ##### #####
# Copy files and clean up.

CMD="cp $TEMPDIR${arr[0]}_stats.txt.gz ./bams/"
echo $CMD
#eval $CMD



# Clean up, delete files.

CMD="rm $TEMPDIR${arr[0]}.sam"
echo $CMD
#eval $CMD


# EOF.
