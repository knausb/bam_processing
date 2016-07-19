#$ -S /bin/bash

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
# $ -t 1-10:1
#$ -t 11-4921

i=$(expr $SGE_TASK_ID - 1)

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"

#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar"
GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.5.jar"
#GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK-3.6.jar"

REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/bjk_pinf_ref/pinf_super_contigs.fa"

FILE=( `cat "bams1.txt" `)

IFS=',' read -r -a arr <<< "${FILE[$i]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date

CMD="$JAVA -version"
echo $CMD
eval $CMD

# https://www.broadinstitute.org/gatk/documentation/article?id=3893
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_engine_CommandLineGATK.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php

CMD="$JAVA -jar $GATK \
  -T GenotypeGVCFs \
  -R $REF \
  -L Supercontig_1.$SGE_TASK_ID \
  -o gvcfgt1/sc_1.$SGE_TASK_ID.vcf \
  --variant gvcf/inf1.g.vcf \
  --variant gvcf/inf2.g.vcf \
  --variant gvcf/inf3.g.vcf \
  --variant gvcf/inf4.g.vcf \
  --variant gvcf/inf5.g.vcf \
  --variant gvcf/inf6.g.vcf \
  --variant gvcf_tri/DDR7602.g.vcf \
  --variant gvcf_tri/LBUS5.g.vcf \
  --variant gvcf_tri/P1362.g.vcf \
  --variant gvcf_tri/P6096.g.vcf \
  --variant gvcf_tri/us8.g.vcf \
  --variant gvcf_tri/RS2009P1_us8.g.vcf \
  --variant gvcf_tri/us11.g.vcf \
  --variant gvcf/P10127.g.vcf \
  --variant gvcf/us22.g.vcf \
  --variant gvcf/P17777us22A.g.vcf \
  --variant gvcf/IN2009T1_us22.g.vcf \
  --variant gvcf_tri/BL2009P4_us23.g.vcf \
  --variant gvcf_tri/us23.g.vcf \
  --variant gvcf_tri/us24.g.vcf"

echo $CMD

if [ ! -f gvcfgt1/sc_1.$SGE_TASK_ID.vcf.idx ]
then
eval $CMD
fi

date

# EOF.
