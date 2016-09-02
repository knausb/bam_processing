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


## Indel realignment

Indels may create alignment issues and these issues may be inconsistent among read mappings.
Here we realign the reads around indels.
First we use RealignerTargetCreator to identify indels.
This results in a **.intervals** file for each sample.
We then use IndelRealigner to perform local realignments.
This results in a **_realigned.bam** file.
Finally, SAMtools calmd is used resulting in a **_calmd file**.


## PCR duplicate removal


## Variant calling


