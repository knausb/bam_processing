#$ -S /bin/bash

#$ -N chrg
#$ -o chrgout
#$ -e chrgerr
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q !gbs

# #$ -l mem_free=2G
# $ -p -10
# #$ -h
#$ -t 1-5:1
# $ -t 5-4921

i=$(expr $SGE_TASK_ID - 1)

#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar"
GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.5.jar"
#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.6.jar"
JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"
PIC="/home/bpp/knausb/bin/picard/picard-tools-2.5.0/picard.jar"
REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"
SAMT="~/bin/samtools-1.3.1/samtools"

SAMPS=("HPM-200" "HPM-527" "HPM-663" "HPM-693" "HPM-867")
ANNOT="C"

#EVAL="TRUE"
EVAL="FALSE"

#FILE=( `cat "bams1.txt" `)

#IFS=',' read -r -a arr <<< "${FILE[$i]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

CMD="$JAVA -version 2>&1"
echo $CMD
eval $CMD
echo

date

CMD="$JAVA -jar $PIC AddOrReplaceReadGroups \
      I=${SAMPS[$i]}_fixed.bam \
      O=${SAMPS[$i]}"$ANNOT"_fixed.bam \
      RGID=${SAMPS[$i]}"$ANNOT" \
      RGLB=${SAMPS[$i]}"$ANNOT" \
      RGPL=illumina \
      RGPU=${SAMPS[$i]}"$ANNOT" \
      RGSM=${SAMPS[$i]}"$ANNOT

echo $CMD
if [ "$EVAL" == "TRUE" ]; then
  eval $CMD
  echo
fi

date

# Index
CMD="$SAMT index ${SAMPS[$i]}"$ANNOT"_fixed.bam"
echo $CMD
#
if [ "$EVAL" == "TRUE" ]; then
  eval $CMD
  echo
fi

date

