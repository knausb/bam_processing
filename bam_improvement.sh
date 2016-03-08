#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N bamimp
#$ -o bamimp_out
#$ -e bamimp_err
# #$ -l mem_free=2G
#$ -V
#$ -q !gbs
#$ -t 1-51:1

echo "SGE_TASK_ID: "
echo $SGE_TASK_ID
echo

i=$(expr $SGE_TASK_ID - 1)

PATH=~/bin/gatk/:$PATH

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

echo "0: "
${arr[0]}
echo "1: "
${arr[1]}
echo "2: "
${arr[2]}
echo "3: "
${arr[3]}
echo
echo

# https://www.broadinstitute.org/gatk/guide/article?id=38

CMD="/home/bpp/knausb/bin/javadir/jre1.7.0_71/bin/java -Xmx1g \
     -jar /home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar \
     -T RealignerTargetCreator \
     -R $REF -I ${arr[3]} -o indels/${arr[0]}.intervals \
     -known ./pitg_indels.vcf"

echo $CMD
date
eval $CMD
date
echo

CMD="/home/bpp/knausb/bin/javadir/jre1.7.0_71/bin/java -Xmx4g \
     -Djava.io.tmpdir=/data -jar /home/bpp/knausb/bin/gatk/GenomeAnalysisTK.jar \
     -T IndelRealigner -R $REF -I ${arr[3]} \
     -targetIntervals indels/${arr[0]}.intervals \
     -o bams/${arr[0]}.bam \
     --consensusDeterminationModel USE_READS -LOD 0.4"

echo $CMD
date
eval $CMD
date
echo

# EOF
