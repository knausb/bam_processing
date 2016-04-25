#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N pe
#$ -e bwa0err
#$ -o bwa0out
#$ -q !gbs
# #$ -l mem_free=10G
#$ -V
# #$ -h
#$ -t 1-5:1

i=$(expr $SGE_TASK_ID - 1)

SAMT="~/bin/samtools-1.1/samtools"
PATH=~/bin/samtools-1.1:$PATH
echo $PATH
echo

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"

FILE=( `cat "samples.txt" `)

IFS=';' read -a arr <<< "${FILE[$i]}"

echo "${arr[1]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date

# Align reads with bwa.
CMD="~/bin/bwa-0.7.10/bwa mem -M -R @RG'\t'ID:${arr[0]}'\t'SM:${arr[0]} $REF ${arr[1]} ${arr[2]} > sams/${arr[0]}.sam"
#echo $CMD
#eval $CMD

date


# Echo samtools version info.
CMD="$SAMT --version"
#eval $CMD

# view
# -b       output BAM
# -S       ignored (input format is auto-detected)
# -u       uncompressed BAM output (implies -b)

# sort
# -n         Sort by read name
# -o FILE  output file name [stdout]
# -O FORMAT  Write output as FORMAT ('sam'/'bam'/'cram')   (either -O or
# -T PREFIX  Write temporary files to PREFIX.nnnn.bam       -T is required)

# fillmd
# -u       uncompressed BAM output (for piping)

# Fix mate information and add the MD tag.
CMD="$SAMT view -bSu sams/${arr[0]}.sam | $SAMT sort -n -O bam -o bams/${arr[0]}_nsort -T bams/${arr[0]}_nsort_tmp"
#echo $CMD
#eval $CMD

CMD="$SAMT fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | $SAMT sort -O bam -o - -T bams/${arr[0]}_csort_tmp | $SAMT fillmd -u - $REF > bams/${arr[0]}_fixed.bam"
#echo $CMD
#eval $CMD


echo "Samtools done"

date
