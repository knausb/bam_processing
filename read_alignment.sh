#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N pe
#$ -o sout
#$ -e serr
#$ -q !gbs
# #$ -l mem_free=10G
#$ -V
#$ -t 1-25:1

i=$(expr $SGE_TASK_ID - 1)

#PATH=/raid1/home/bpp/knausb/bin/samtools-0.1.18/bcftools/:$PATH

PATH=~/bin/samtools-1.1:$PATH
echo "Path:"
echo $PATH
echo ""

REF="/nfs/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"

declare -a FWD=(
'../pinf_fqs/1306_1_pair1.fq.gz'
'../pinf_fqs/1306_2_pair1.fq.gz'
'../pinf_fqs/1306_3_pair1.fq.gz'
'../pinf_fqs/BL2009P4_us23_pair1.fq.gz'
'../pinf_fqs/blue13_L_name.fq.gz'
'../pinf_fqs/DDR7602_L.fq.gz'
'../pinf_fqs/IN2009T1_us22_pair1.fq.gz'
'../pinf_fqs/LBUS5_L.fq.gz'
'../pinf_fqs/NL07434_L_name.fq.gz'
'../pinf_fqs/P10127_fwd.fq.gz'
'../pinf_fqs/P10650_fwd.fq.gz'
'../pinf_fqs/P11633_fwd.fq.gz'
'../pinf_fqs/P12204_fwd.fq.gz'
'../pinf_fqs/P13527_L.fq.gz'
'../pinf_fqs/P13626_L.fq.gz'
'../pinf_fqs/P1362_fwd.fq.gz'
'../pinf_fqs/P17777us22_L_name.fq.gz'
'../pinf_fqs/P6096_fwd.fq.gz'
'../pinf_fqs/P7722_fwd.fq.gz'
'../pinf_fqs/RS2009P1_us8_pair1.fq.gz'
'../pinf_fqs/us11_pair1.fq.gz'
'../pinf_fqs/us22_pair1.fq.gz'
'../pinf_fqs/us23_pair1.fq.gz'
'../pinf_fqs/us24_pair1.fq.gz'
'../pinf_fqs/us8_pair1.fq.gz'
)

declare -a REV=(
'../pinf_fqs/1306_1_pair2.fq.gz'
'../pinf_fqs/1306_2_pair2.fq.gz'
'../pinf_fqs/1306_3_pair2.fq.gz'
'../pinf_fqs/BL2009P4_us23_pair2.fq.gz'
'../pinf_fqs/blue13_R_name.fq.gz'
'../pinf_fqs/DDR7602_R.fq.gz'
'../pinf_fqs/IN2009T1_us22_pair2.fq.gz'
'../pinf_fqs/LBUS5_R.fq.gz'
'../pinf_fqs/NL07434_R_name.fq.gz'
'../pinf_fqs/P10127_rev.fq.gz'
'../pinf_fqs/P10650_rev.fq.gz'
'../pinf_fqs/P11633_rev.fq.gz'
'../pinf_fqs/P12204_rev.fq.gz'
'../pinf_fqs/P13527_R.fq.gz'
'../pinf_fqs/P13626_R.fq.gz'
'../pinf_fqs/P1362_rev.fq.gz'
'../pinf_fqs/P17777us22_R_name.fq.gz'
'../pinf_fqs/P6096_rev.fq.gz'
'../pinf_fqs/P7722_rev.fq.gz'
'../pinf_fqs/RS2009P1_us8_pair2.fq.gz'
'../pinf_fqs/us11_pair2.fq.gz'
'../pinf_fqs/us22_pair2.fq.gz'
'../pinf_fqs/us23_pair2.fq.gz'
'../pinf_fqs/us24_pair2.fq.gz'
'../pinf_fqs/us8_pair2.fq.gz'
)

declare -a NAMES=(
'1306_1'
'1306_2'
'1306_3'
'BL2009P4_us23'
'blue13'
'DDR7602'
'IN2009T1_us22'
'LBUS5'
'NL07434'
'P10127'
'P10650'
'P11633'
'P12204'
'P13527'
'P13626'
'P1362'
'P17777us22'
'P6096'
'P7722'
'RS2009P1_us8'
'us11'
'us22'
'us23'
'us24'
'us8'
)

date

~/bin/bwa-0.7.10/bwa mem -M -R '@RG\tID:'${NAMES[$i]}'\tSM:'${NAMES[$i]} $REF ${FWD[$i]} ${REV[$i]} > 'sams/'${NAMES[$i]}'.sam' 

date

CMD="samtools view -bS -o bams/${NAMES[$i]}.bam sams/${NAMES[$i]}.sam"
echo $CMD
$CMD

CMD="samtools sort bams/${NAMES[$i]}.bam bams/${NAMES[$i]}.sorted"
echo $CMD
$CMD

CMD="samtools index bams/${NAMES[$i]}.sorted.bam"
echo $CMD
$CMD

CMD="samtools view -bSu sams/${NAMES[$i]}.sam | samtools sort -n -O bam -T bams/${NAMES[$i]}_samtools_nsort_tmp | samtools fixmate /dev/stdin bams/${NAMES[$i]}.fmsorted.bam"
echo $CMD
eval $CMD

CMD="samtools sort -O bam -T bams/${NAMES[$i]}_samtools_csort_tmp -o bams/${NAMES[$i]}_csort.bam bams/${NAMES[$i]}.fmsorted.bam"
echo $CMD
eval $CMD

CMD="samtools index bams/${NAMES[$i]}_csort.bam"
echo $CMD
eval $CMD

echo "Samtools done"

date
