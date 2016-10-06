#!/bin/bash

# The SRA has has the SRAtoolkit for data transfer and formatting.
# This is an example of how I downloaded some SRA data.

#prefetch SRR066510
#mv ~/ncbi/public/sra/SRR066510.sra .
#prefetch SRR066511
#mv ~/ncbi/public/sra/SRR066511.sra .
prefetch SRR066512
mv ~/ncbi/public/sra/SRR066512.sra .
prefetch SRR066513
mv ~/ncbi/public/sra/SRR066513.sra .
prefetch SRR066514
mv ~/ncbi/public/sra/SRR066514.sra .
prefetch SRR066515
mv ~/ncbi/public/sra/SRR066515.sra .
prefetch SRR066516
mv ~/ncbi/public/sra/SRR066516.sra .

# Once you have downloaded the data you'll probably want to convert it to fastq format.
# See the script fqdump for that.

