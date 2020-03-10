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
# $ -t 1-5:1
# $ -t 6-50:1
# $ -t 51-100:1
#$ -t 101-192:1

i=$(expr $SGE_TASK_ID - 1)

TEMPDIR="/data/"

echo "PATH:"
echo $PATH
echo

##### ##### ##### ##### #####
# Software

# http://bio-bwa.sourceforge.net/bwa.shtml
BWA="~/bin/bwa-0.7.17/bwa"

SAMT="~/bin/samtools-1.9/samtools-1.9/samtools "

# MarkDuplicates (Picard)
# SortSam (Picard)
# https://gatk.broadinstitute.org/hc/en-us/articles/360037225972-MarkDuplicates-Picard-
# http://broadinstitute.github.io/picard/
# http://broadinstitute.github.io/picard/command-line-overview.html
PICARD="~/bin/picard/picard_2.21.6/picard.jar"

# https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows
GATK="~/bin/gatk4/gatk-4.1.4.1/gatk"

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"


##### ##### ##### ##### #####
# User provided materials

# Reference sequence
#REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"
#
BREF="bwaref/Pr-102_v3.1.fasta"

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

# http://bio-bwa.sourceforge.net/bwa.shtml
# Align reads with bwa.

# Report bwa version info.
echo "bwa info"
CMD="$BWA 2>&1"
echo
echo $CMD
eval $CMD
echo

# http://www.htslib.org/doc/
# Echo samtools version info.
echo "samtools info"
CMD="$SAMT --version"
echo
eval $CMD
echo

# Picard version.
echo "picard info"
CMD="$JAVA -jar $PICARD MarkDuplicates --version 2>&1"
echo $CMD
eval $CMD
echo

echo "GATK info"
CMD="~/bin/gatk4/gatk-4.1.4.1/gatk --version"
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
# Map reads

# The GATK needs read group info:
# https://software.broadinstitute.org/gatk/guide/article?id=6472
# SM: sample
# LB: library, may be sequenced multiple times
# ID: Read Group Identifier, a unique identifier
# PL: Platform/technology used

RG="@RG\tID:${arr[0]}\tLB:${arr[0]}\tPL:illumina\tSM:${arr[0]}\tPU:${arr[0]}"

CMD="$BWA mem -M -R \"$RG\" $BREF ${arr[1]} ${arr[2]} > $TEMPDIR${arr[0]}.sam"

echo
#
echo $CMD
#
eval $CMD
echo

date


##### ##### ##### ##### #####
# Generate stats to validate the sam.
CMD="$SAMT stats $TEMPDIR${arr[0]}.sam | gzip -c > $TEMPDIR${arr[0]}_stats.txt.gz"
echo $CMD
#
eval $CMD
echo


##### ##### ##### ##### #####
# Mark duplicates and sort

# Mark duplicates.

# http://gatkforums.broadinstitute.org/dsde/discussion/comment/28837/#Comment_28837
# One thing MarkDuplicates attempts is to identify reads that were physically
# close to one another on the flow cell.
# If you got your reads from an online database this information may have been
# removed from each sequence's header.
# If this is your case you may want to include:
# READ_NAME_REGEX=null

# Sort
CMD="$JAVA -Djava.io.tmpdir=/data/ \
     -jar $PICARD SortSam \
     I=$TEMPDIR${arr[0]}.sam \
     O=$TEMPDIR${arr[0]}_sorted.bam \
     TMP_DIR=/data/ \
     SORT_ORDER=coordinate"

date
echo
echo $CMD
#
eval $CMD
date


# Mark duplicates
CMD="$JAVA -Djava.io.tmpdir=/data/ \
     -jar $PICARD MarkDuplicates \
     I=$TEMPDIR${arr[0]}_sorted.bam \
     O=$TEMPDIR${arr[0]}_dupmrk.bam \
     MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000 \
     ASSUME_SORT_ORDER=coordinate \
     M=$TEMPDIR${arr[0]}_marked_dup_metrics.txt"

date
echo
echo $CMD
#
eval $CMD
date



##### ##### ##### ##### #####
# Index

#CMD="$SAMT index bams/${arr[0]}_sorted.bam"
CMD="$SAMT index $TEMPDIR${arr[0]}_dupmrk.bam"

echo $CMD
#
eval $CMD
date

# Generate stats to validate the bam.
#CMD="$SAMT stats bams/${arr[0]}_sorted.bam | gzip -c > bams/${arr[0]}_sorted_stats.txt.gz"
CMD="$SAMT stats $TEMPDIR${arr[0]}_dupmrk.bam | gzip -c > $TEMPDIR${arr[0]}_dupmrk_stats.txt.gz"


echo $CMD
#
eval $CMD

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch


##### ##### ##### ##### #####
# Create gvcf

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\" HaplotypeCaller \
   -R $GREF \
   -I $TEMPDIR${arr[0]}_dupmrk.bam \
   -O $TEMPDIR${arr[0]}.g.vcf.gz \
   -ERC GVCF"

echo $CMD
#
eval $CMD

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch

date

##### ##### ##### ##### #####
# Copy files and clean up.

CMD="cp $TEMPDIR${arr[0]}_stats.txt.gz ./bams/"
echo $CMD
eval $CMD

CMD="cp $TEMPDIR${arr[0]}_dupmrk.bam ./bams/"
echo $CMD
eval $CMD

CMD="cp $TEMPDIR${arr[0]}_dupmrk.bam.bai ./bams/"
echo $CMD
eval $CMD

CMD="cp $TEMPDIR${arr[0]}_dupmrk_stats.txt.gz ./bams/"
echo $CMD
eval $CMD

CMD="cp $TEMPDIR${arr[0]}.g.vcf.gz ./gvcfs/"
echo $CMD
eval $CMD

# Clean up, delete files.

CMD="rm $TEMPDIR${arr[0]}.sam"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}_stats.txt.gz"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}_sorted.bam"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}_dupmrk.bam"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}_dupmrk.bam.bai"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}_dupmrk_stats.txt.gz"
echo $CMD
#
eval $CMD

CMD="rm $TEMPDIR${arr[0]}.g.vcf.gz"
echo $CMD
#
eval $CMD

# EOF.
