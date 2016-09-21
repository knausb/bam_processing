#$ -S /bin/bash

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

CMD="$JAVA -version"
echo $CMD
eval $CMD
echo

CMD="$JAVA -jar $GATK --version"
echo $CMD
eval $CMD
echo

CMD="$JAVA -jar $GATK -T HaplotypeCaller --version"
echo $CMD
eval $CMD
echo

# https://www.broadinstitute.org/gatk/documentation/article?id=3893
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
# https://www.broadinstitute.org/gatk/documentation/tooldocs/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php

CMD="$JAVA -jar $GATK -Djava.io.tmpdir=/data/ \
  -T HaplotypeCaller \
  -R $REF \
  --emitRefConfidence GVCF \
  -ploidy 2 \
  -I RGbams/${arr[0]}.bam \
  -o gvcf/${arr[0]}_2n.g.vcf"

echo $CMD
eval $CMD

# EOF.
