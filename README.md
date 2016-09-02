# bam_processing
Process SAM/BAM files accroding to the 1k genomes methods

The 1,000 genomes project has posted its [bam processing methods](https://github.com/igsr/1000Genomes_data_indexes/blob/master/historical_data/former_toplevel/README.alignment_data.md) online.
This repository documents how I implement their methodology in our projects on our SGE computing facility.

The process has several steps.

* Read alignment, including SAM to BAM conversion, sort and index
* Indel realignment and quality adjustment - requires **known** variants, which we typically lack so this step is omitted
* PCR duplicate removal


## Read alignment

Read alignment is currently performed using bwa, however there are a number of options here.
Read alignment uses fastq (**.fastq.gz**) files as input and a SAM file (**.sam**) is output.
Subsequent to read alignment, a few steps are performed with SAMtools.
First we fix mate information and add the MD tag.
This will generate an out file named **_nsort**.
This file is resorted resulting in a **_fixed.bam** file.

**Retained file:**
\*_fixed.bam.

**Removed files:**
\*_nsort, \*_nsort_tmp, \*_csort_tmp.
(_tmp files should be automatically removed.)


## BAM improvement (indel realignment)

Indels may create alignment issues and these issues may be inconsistent among read mappings.
Here we realign the reads around indels.
First we use RealignerTargetCreator to identify indels.
This results in a **.intervals** file for each sample.
We then use IndelRealigner to perform local realignments.
This results in a **_realigned.bam** file.
Finally, SAMtools calmd is used resulting in a **_calmd.bam** file.

**Retained files:**
\*.intervals and \*_calmd.bam.

**Removed files:**
\*_realigned.bam

## PCR duplicate removal

Reads that begin at the same position may be considered to be duplicates created by PCR.
It may be desireable to manage these.
They can be either marked with Picard or removed with SAMtools.

This step is not very intensive so no retained files are necessary.


## Variant calling

Variant calling is currently performed using several steps from the GATK.
First, a genomic variant call format (gVCF) file is created for each sample.
Processing of each sample independently allows for the specification of different ploidys for different samples.
Then these gVCF files are used to call variants.
We use the HaplotypeCaller with the --emitRefConfidence GVCF option.
This results in a **.g.vcf** file.
Once we have a set of gVCF files we can call GenotypeGVCFs to call variants which results in a VCF file.

**Retained files:**
\*.g.vcf file for each sample and a \*.vcf file containing the final variants.




