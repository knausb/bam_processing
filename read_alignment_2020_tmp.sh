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
#$ -t 1-2:1

i=$(expr $SGE_TASK_ID - 1)

echo "PATH:"
echo $PATH
echo

##### ##### ##### ##### #####
# User provided materials

#EVAL="TRUE"
EVAL="FALSE"

# Reference sequence
#REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"
#
BREF="bwaref/pinfsc50b.fa"

# GATK reference
GREF="gatkref/pinfsc50b.fa"


# The file samples.txt contains info about sample names and files.
# Each line is one sample and one job.
# The line is a semi colon delimited list.
# The first element is the sample name.
# The second element is the fastq file including any path info.
#
# t30-4;../fastqs/ATCGGC.fastq.gz
#

FILE=( `cat "samples.txt" `)
IFS=';' read -a arr <<< "${FILE[$i]}"
echo "${arr[1]}"

# Our system has scratch space on each worker node.
# This distributes load on the hard drives.
TEMP="/data/knausb/"


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
# Report what we ended up with

echo "Evaluate: "$EVAL
echo


echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

bEpoch=(`date +%s`)
echo "Epoch start:" $bEpoch

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
# Processing

echo "##### ##### ##### ##### #####"
echo "Begin processing."

if [ ! -d "$TEMP" ]; then
  CMD="mkdir $TEMP"
  echo $CMD
  if [[ $EVAL == "TRUE" ]]; then
    eval $CMD
  fi
fi

##### ##### ##### ##### #####
# Map reads

# The GATK needs read group info:
# https://software.broadinstitute.org/gatk/guide/article?id=6472
# SM: sample
# LB: library, may be sequenced multiple times
# ID: Read Group Identifier, a unique identifier
# PL: Platform/technology used

RG="@RG\tID:${arr[0]}\tLB:${arr[0]}\tPL:illumina\tSM:${arr[0]}\tPU:${arr[0]}"

CMD="$BWA mem -M -R \"$RG\" $BREF ${arr[1]} ${arr[2]} > "$TEMP${arr[0]}".sam"

echo
#
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi
echo

date
echo

##### ##### ##### ##### #####
# Generate stats to validate the sam.
CMD="$SAMT stats $TEMP${arr[0]}.sam | gzip -c > $TEMP${arr[0]}_stats.txt.gz"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi
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
     I=$TEMP${arr[0]}.sam \
     O=$TEMP${arr[0]}_sorted.bam \
     TMP_DIR=/data/ \
     SORT_ORDER=coordinate"

date
echo
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi
echo
date
echo

# Mark duplicates
CMD="$JAVA -Djava.io.tmpdir=/data/ \
     -jar $PICARD MarkDuplicates \
     I=$TEMP${arr[0]}_sorted.bam \
     O=$TEMP${arr[0]}_dupmrk.bam \
     MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000 \
     ASSUME_SORT_ORDER=coordinate \
     M=$TEMP${arr[0]}_marked_dup_metrics.txt"

#date
#echo
echo $CMD
#eval $CMD
echo
date
echo


##### ##### ##### ##### #####
# Index
#CMD="$SAMT index $TEMP${arr[0]}_sorted.bam"
CMD="$SAMT index $TEMP${arr[0]}_dupmrk.bam"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi
echo
date
echo


# Generate stats to validate the bam.
CMD="$SAMT stats $TEMP${arr[0]}_dupmark.bam | gzip -c > $TEMP${arr[0]}_dupmark_stats.txt.gz"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

#myEpoch=(`date +%s`)
#echo "Epoch start:" $myEpoch


##### ##### ##### ##### #####
# Create gvcf

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\" HaplotypeCaller \
   -R $GREF \
   -I $TEMP${arr[0]}_dupmrk.bam \
   -O $TEMP${arr[0]}.g.vcf.gz \
   -ERC GVCF"

#   -I $TEMP${arr[0]}_sorted.bam \


echo
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi
echo

##### ##### ##### ##### #####
# Manage files.

echo
echo "##### ##### ##### ##### #####"
echo "Managing files"

CMD="cp $TEMP${arr[0]}.sam ."
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}.sam"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="cp $TEMP${arr[0]}_stats.txt.gz ."
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}_stats.txt.gz"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}_sorted.bam"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}_dupmrk.bam"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}_dupmrk.bam.bai"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="cp $TEMP${arr[0]}.g.vcf.gz ."
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi

CMD="rm -f $TEMP${arr[0]}.g.vcf.gz"
echo $CMD
if [[ $EVAL == "TRUE" ]]; then
  eval $CMD
fi


##### ##### ##### ##### #####

eEpoch=(`date +%s`)
echo
echo "Epoch begin:" $bEpoch
echo "Epoch end:" $eEpoch
echo $((eEpoch-bEpoch))

# EOF.
