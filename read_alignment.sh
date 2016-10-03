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

# http://bio-bwa.sourceforge.net/bwa.shtml
BWA="~/bin/bwa-0.7.10/bwa"

# http://www.htslib.org/doc/
#SAMT="~/bin/samtools-1.1/samtools"
SAMT="~/bin/samtools-1.3.1/samtools"

echo "PATH:"
PATH=~/bin/samtools-1.3.1:$PATH
echo $PATH
echo

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"

# http://broadinstitute.github.io/picard/
# http://broadinstitute.github.io/picard/command-line-overview.html
PIC="~/bin/picard/picard-tools-2.5.0/picard.jar"

#
REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"
#REF="bwaref/pinfsc50b.fa"

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

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

# http://bio-bwa.sourceforge.net/bwa.shtml
# Align reads with bwa.

# Report version info.
CMD="$BWA 2>&1"
echo
echo $CMD
eval $CMD
echo

# The GATK needs read group info:
# https://software.broadinstitute.org/gatk/guide/article?id=6472

RG="@RG\tID:${arr[0]}\tLB:${arr[0]}\tPL:illumina\tSM:${arr[0]}\tPU:${arr[0]}"

CMD="$BWA mem -M -R \"$RG\" $REF ${arr[1]} ${arr[2]} > sams/${arr[0]}.sam"

echo
#
echo $CMD
#
eval $CMD
echo

date

# http://www.htslib.org/doc/
# Echo samtools version info.
CMD="$SAMT --version"
echo
eval $CMD
echo

# view
# -b       output BAM
# -S       ignored (input format is auto-detected)
# -u       uncompressed BAM output (implies -b)

# sort
# -n         Sort by read name
# -o FILE  output file name [stdout]
# -O FORMAT  Write output as FORMAT ('sam'/'bam'/'cram')   (either -O or
# -T PREFIX  Write temporary files to PREFIX.nnnn.bam       -T is required)

# fillmd (deprecated, see calmd)
# -u       uncompressed BAM output (for piping)

# calmd
# -u       uncompressed BAM output (for piping)

# Generate stats to validate the sam.
CMD="$SAMT stats sams/${arr[0]}.sam | gzip -c > sams/${arr[0]}_stats.txt.gz"
echo $CMD
eval $CMD

# Fix mate information and add the MD tag.
# http://samtools.github.io/hts-specs/
# MD = String for mismatching positions
# NM = Edit distance to the reference
CMD="$SAMT view -bSu sams/${arr[0]}.sam | $SAMT sort -n -O bam -o bams/${arr[0]}_nsort -T bams/${arr[0]}_nsort_tmp"
#
echo $CMD
#
eval $CMD

# CMD="$SAMT fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | $SAMT sort -O bam -o - -T bams/${arr[0]}_csort_tmp | $SAMT fillmd -u - $REF > bams/${arr[0]}_fixed.bam"
# CMD="$SAMT fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | $SAMT sort -O bam -o - -T bams/${arr[0]}_csort_tmp | $SAMT fillmd -u - $REF | $SAMT view -b > bams/${arr[0]}_fixed.bam"
CMD="$SAMT fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | $SAMT sort -O bam -o - -T bams/${arr[0]}_csort_tmp | $SAMT calmd -u - $REF | $SAMT view -b > bams/${arr[0]}_fixed.bam"

#
echo $CMD
#
eval $CMD

# Generate stats to validate the bam.
CMD="$SAMT stats bams/${arr[0]}_fixed.bam | gzip -c > bams/${arr[0]}_fixed_stats.txt.gz"
echo $CMD
eval $CMD

echo
echo "Samtools done"
echo

date

# Mark duplicates.

CMD="$JAVA -version 2>&1"
echo $CMD
eval $CMD
echo

CMD="$JAVA -jar $PIC MarkDuplicates --version 2>&1"
echo $CMD
eval $CMD
echo

CMD="$JAVA -Djava.io.tmpdir=/data/ \
     -jar $PIC MarkDuplicates \
     I=bams/${arr[0]}_fixed.bam \
     O=bams/${arr[0]}_dupmrk.bam \
     ASSUME_SORT_ORDER=coordinate \
     M=bams/${arr[0]}_marked_dup_metrics.txt"

date
echo
echo $CMD
#
eval $CMD
date

# Index
CMD="$SAMT index bams/${arr[0]}_dupmrk.bam"
echo $CMD
#
eval $CMD
date

# Generate stats to validate the bam.
CMD="$SAMT stats bams/${arr[0]}_dupmrk.bam | gzip -c > bams/${arr[0]}_dupmrk_stats.txt.gz"
echo $CMD
#
eval $CMD

# EOF.
