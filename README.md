# bam_processing
Process SAM/BAM files accroding to the 1k genomes methods

The 1,000 genomes project has posted its [bam processing methods](https://github.com/igsr/1000Genomes_data_indexes/blob/master/historical_data/former_toplevel/README.alignment_data.md) online.
This repository documents how I implement their methodology in our projects on our SGE computing facility.

The process has several steps.

* Read alignment
* SAM to BAM, sort and index
* Indel realignment and quality adjustment
* PCR duplicate removal


