#! /bin/bash

#$ -N gtgvcf
#$ -o gtgvcfout
#$ -e gtgvcferr
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q !gbs

# #$ -l mem_free=2G
# $ -p -10
# #$ -h
#$ -t 50-50:1
# $ -t 5-4921

i=$(expr $SGE_TASK_ID - 1)

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"

#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar"
GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.5.jar"
#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.6.jar"

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

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

CMD="$JAVA -jar $GATK --version"
echo $CMD
eval $CMD
echo

# https://www.broadinstitute.org/gatk/documentation/article?id=3893
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_engine_CommandLineGATK.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php

CMD="$JAVA -Djava.io.tmpdir=/data/ \
  -jar $GATK \
  -T GenotypeGVCFs \
  -R $REF \
  -L Supercontig_1.$SGE_TASK_ID \
  -V gvcfs.list \
  -o vcfs/sc_1.$SGE_TASK_ID.vcf.gz"

echo $CMD
eval $CMD

date

# EOF.
