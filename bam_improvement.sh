#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N bamimp
#$ -o bamimp_out
#$ -e bamimp_err
# #$ -l mem_free=2G
#$ -V
#$ -q !gbs
#$ -t 1-5:1

# Note that the Broad no longer recommends indel realignment.
# As such, this script may be considered deprecated.
#
# https://software.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_gatk_tools_walkers_indels_RealignerTargetCreator.php



echo "SGE_TASK_ID: "
echo $SGE_TASK_ID
echo

i=$(expr $SGE_TASK_ID - 1)

PATH=~/bin/gatk/:$PATH
PATH=~/bin/samtools-1.1:$PATH
GATK="/home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar"
SAMT="~/bin/samtools-1.1/samtools"

export _JAVA_OPTIONS="-XX:ParallelGCThreads=1"

BAM=( `cat "./bams.txt" `)

IFS=';' read -a arr <<< "${BAM[$i]}"

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

echo "Sample name 0: "
echo ${arr[0]}
echo "Input bam file 1: "
echo ${arr[1]}
echo
echo

# https://www.broadinstitute.org/gatk/guide/article?id=38

CMD="/home/bpp/knausb/bin/javadir/jre1.7.0_71/bin/java -Xmx1g \
     -jar $GATK \
     -T RealignerTargetCreator \
#     --fix_misencoded_quality_scores \ # For non-Sanger encoded qualities.
     -R $REF \
     -I ${arr[1]} \
     -o bams/${arr[0]}.intervals \
     -known ./pitg_indels.vcf"

echo $CMD
date
eval $CMD
date
echo

CMD="/home/bpp/knausb/bin/javadir/jre1.7.0_71/bin/java -Xmx4g \
     -Djava.io.tmpdir=/data \
     -jar $GATK \
     -T IndelRealigner \
     -R $REF \
     -I ${arr[1]} \
     -targetIntervals bams/${arr[0]}.intervals \
     -o bams/${arr[0]}_realigned.bam \
     --consensusDeterminationModel USE_READS -LOD 0.4"

echo $CMD
date
eval $CMD
date
echo

CMD="$SAMT calmd -Erb bams/${arr[0]}_realigned.bam $REF > bams/${arr[0]}_calmd.bam"

echo $CMD
date
eval $CMD
date
echo

# EOF
