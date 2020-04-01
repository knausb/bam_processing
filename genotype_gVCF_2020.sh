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
# $ -t 50-50:1
# $ -t 5-4921

i=$(expr $SGE_TASK_ID - 1)

GATK="~/bin/gatk4/gatk-4.1.4.1/gatk"

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"


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


# https://gatk.broadinstitute.org/hc/en-us/articles/360037427071-CombineGVCFs

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\" CombineGVCFs \
     -R $REF \
     -L Supercontig_1.$SGE_TASK_ID \
     -TMP_DIR /data/ \
     --variant sample1.g.vcf.gz \
     --variant sample2.g.vcf.gz \
     -O gvcfs/cohort_$SGE_TASK_ID.g.vcf.gz"

echo $CMD
eval $CMD

# https://gatk.broadinstitute.org/hc/en-us/articles/360037057852-GenotypeGVCFs

CMD="$GATK --java-options \"-Djava.io.tmpdir=/data/ -Xmx4g\" GenotypeGVCFs \
  -R $REF \
  -TMP_DIR /data/ \
  -V gvcfs/cohort_$SGE_TASK_ID.g.vcf.gz\
  -o vcfs/sc_1.$SGE_TASK_ID.vcf.gz"

echo $CMD
eval $CMD

date

# EOF.
