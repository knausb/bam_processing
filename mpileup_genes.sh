#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N mpile
#$ -o mpile_out
#$ -e mpile_err
# #$ -l mem_free=2G
#$ -V
# #$ -q !(gbs|grungall1)
#$ -q !gbs
# #$ -h
# #$ -t 1-51:1
#$ -t 11-18179:1
# $ -t 1-10:1


i=$(expr $SGE_TASK_ID - 1)

#PATH=~/bin/samtools-1.1/:$PATH

# http://www.htslib.org/doc/
SAMT="/raid1/home/bpp/knausb/bin/samtools-1.3.1/samtools"


#BAM=( `cat "./bams2.txt" `)
#BED=( `cat "pitg_1based.bed" `)

CHROM=( `cut -f1 pitg_1based.bed` )
START=( `cut -f2 pitg_1based.bed` )
STOP=( `cut -f3 pitg_1based.bed` )
PITG=( `cut -f4 pitg_1based.bed` )

#IFS=';' read -a arr <<< "${BAM[$i]}"
#IFS='\t' read -a arr <<< "${BED[$i]}"

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
echo "SGE_TASK_ID: $SGE_TASK_ID"
date

echo
echo "Path:"
echo $PATH
echo

#CMD="samtools mpileup -f $REF -b bams3.list --positions pitg_core_annotations_unique_sc10.bed | gzip > mpileup_core_sc10.txt.gz"
#CMD="samtools mpileup -f $REF -b ./bams.txt --positions ../pitg_core_annotations_unique_sc19.bed | gzip > mpileup_core_sc19.txt.gz"
#CMD="samtools mpileup -f $REF ${arr[1]} --positions pitg_core_annotations_unique_0based.bed | gzip > core_pu/${arr[0]}.mpileup.gz"

CMD="$SAMT mpileup -b bams.txt -f $REF -r ${CHROM[$i]}:${START[$i]}-${STOP[$i]}  | gzip -c > pitg_pu/${PITG[$i]}.mpileup.gz"

echo $CMD
eval $CMD

date


# EOF.
