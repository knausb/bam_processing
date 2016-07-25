#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N mkref
#$ -o mkref_out
#$ -e mkref_err
# #$ -l mem_free=2G
#$ -V
# #$ -q !(gbs|grungall1)
#$ -q !gbs



JAVA="/home/bpp/knausb/bin/javadir/jre1.8.0_25/bin/java"

PIC="~/bin/picard/picard-tools-2.5.0/picard.jar"

SAMT="~/bin/samtools-1.3.1/samtools"

REF="ref/hop.fa"

# https://software.broadinstitute.org/gatk/guide/article?id=2798


CMD="$SAMT faidx $REF"

echo $CMD
eval $CMD


CMD="$JAVA -jar $PIC CreateSequenceDictionary \
    REFERENCE=$REF \ 
    OUTPUT=$REF.dict"

echo $CMD
eval $CMD

# EOF.
