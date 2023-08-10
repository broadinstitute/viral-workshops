# Viral metagenomics

TO DO - examples with DENV and similar samples

This is a walkthrough demonstrating metagenomic workflows on the Terra cloud platform on Illumina data from arboviral surveillance sampling.

## Data set

TO DO

## Metagenomics pipeline

The exercise will utilize the Broad Viral Genomics group's viral metagenomic classification
pipeline ([Dockstore link](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/classify_single:master?tab=info),
[GitHub source](https://github.com/broadinstitute/viral-pipelines/blob/master/pipes/WDL/workflows/classify_single.wdl),
[Manual](https://viral-pipelines.readthedocs.io/en/latest/classify_single.html)) and
practice execution on the [Terra](https://terra.bio/) platform, but this pipeline is known
to work on other cloud platforms as well as on the command line using miniWDL.

Briefly, the `classify_single` pipeline consists of the following steps:
1. Read-level k-mer based taxonomic classification via kraken2, with krona outputs for visualization
2. Creation of filtered subsets of unaligned reads based on classification: dehosted (all non-vertebrate and unknown), viral (all acellular and unknown), with fastqc plots for each subset
3. Alignment-free duplicate removal, adapter trimming, and *de novo* assembly (via SPAdes) of acellular reads
4. Alignment based counting of reads matching ERCC spike-ins

(note, this does not yet incorporate bracken for more accurate abundance estimation)

## Terra workspace

Describe what's in the tables and what workflows are pre-loaded.

## Walkthrough

### Clone the workspace

### Run classify_single with two different kraken2 databases

### Evaluating results

## Other related resources