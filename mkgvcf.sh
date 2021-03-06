#!/bin/bash

#$ -N mkgvcf
#$ -o mkgvcfout
#$ -e mkgvcferr
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q !gbs

# #$ -l mem_free=2G
# $ -p -10
# #$ -h
# #$ -t 1-10:1
#$ -t 1-51:1

#
i=$(expr $SGE_TASK_ID - 1)

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"

#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar"
GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.5.jar"
#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.6.jar"

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

FILE=( `cat "samples.txt" `)

IFS=';' read -r -a arr <<< "${FILE[$i]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch

CMD="$JAVA -version 2>&1"
echo $CMD
eval $CMD
echo

CMD="$JAVA -jar $GATK --version"
echo $CMD
eval $CMD
echo

date

# https://www.broadinstitute.org/gatk/documentation/article?id=3893
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php

# Note that Haplotypecaller requires an indexed bam.
# If yours is not, use SAMtools.

# If you're dealing with legacy data you may encounter legacy quality encodings.
# If you encounter this use:
#
# --fix_misencoded_quality_scores
#
# In your GATK call. (But only on the offending libraries.)
# https://software.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_gatk_engine_CommandLineGATK.php#--fix_misencoded_quality_scores
# https://en.wikipedia.org/wiki/FASTQ_format


CMD="$JAVA -Djava.io.tmpdir=/data/ -jar $GATK \
  -T HaplotypeCaller \
  -R $REF \
  --emitRefConfidence GVCF \
  -ploidy 2 \
  -I bams/${arr[0]}_dupmrk.bam \
  -o gvcf/${arr[0]}_2n.g.vcf.gz"

echo $CMD
eval $CMD


CMD="$JAVA -Djava.io.tmpdir=/data/ -jar $GATK \
  -T HaplotypeCaller \
  -R $REF \
  --emitRefConfidence GVCF \
  -ploidy 3 \
  -I bams/${arr[0]}_dupmrk.bam \
  -o gvcf/${arr[0]}_3n.g.vcf.gz"

#echo $CMD
#eval $CMD

echo
date
echo "mkgvcf finished."

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch

# EOF.
