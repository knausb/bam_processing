#$ -S /bin/bash

#$ -N mrkdup
#$ -o mrkdupout
#$ -e mrkduperr
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q !gbs
# #$ -l mem_free=2G
# $ -p -10
# #$ -h
# #$ -t 1-10:1
#$ -t 1-5:1

i=$(expr $SGE_TASK_ID - 1)

JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"
PIC="~/bin/picard/picard-tools-2.5.0/picard.jar"

FILE=( `cat "samples.txt" `)
IFS=';' read -a arr <<< "${FILE[$i]}"


echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
date
echo

CMD="$JAVA -version"
echo $CMD
eval $CMD
echo

CMD="$JAVA -jar $PIC --version"
echo $CMD
eval $CMD
echo

# http://broadinstitute.github.io/picard/command-line-overview.html
# https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates

CMD="$JAVA -Djava.io.tmpdir=/data/ -jar $PIC \
     I=bams/${arr[0]}.bam \
     O=mrkdup/${arr[0]}_dupmrk.bam \
     M=mrkdup/${arr[0]}_marked_dup_metrics.txt"


date
echo
echo $CMD
eval $CMD
date


# EOF.

