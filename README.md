# bam_processing
Process SAM/BAM files accroding to the 1k genomes methods

The 1,000 genomes project has posted its [bam processing methods](https://github.com/igsr/1000Genomes_data_indexes/blob/master/historical_data/former_toplevel/README.alignment_data.md) online.
This repository documents how I implement their methodology in our projects on our SGE computing facility.

The process has several steps.

* Read alignment, including SAM to BAM conversion, sort and index. This step now includes fixing matepair data, adding MD and NM tags as well as marking PCR duplicates.
* gVCF creation


## Read alignment

Read alignment is currently performed using bwa, however there are a number of options here.
Read alignment uses fastq (**.fastq.gz**) files as input and a SAM file (**.sam**) is output.
Subsequent to read alignment, a few steps are performed with SAMtools.
First we fix mate information and add the MD tag.
This will generate an out file named **_nsort**.
This file is resorted resulting in a **_fixed.bam** file.
This fixed file then has PCR duplicates marked, is indexed and this step is complete.

**Retained file:**
\*_mrkdup.bam.

**Removed files:**
\*_nsort, \*_nsort_tmp, \*_csort_tmp, \*_fixed.bam..
(_tmp files should be automatically removed.)


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




