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

For simplicity, we have already loaded in the read data and the reference databases. If you are starting from scratch on a new
data set, what we did to populate these workspaces was:

1. Imported the following workflows from the Broad Institute Viral Genomics
[Dockstore collection](https://dockstore.org/organizations/BroadInstitute/collections/pgs):
`fastq_to_ubam`, `classify_single`.
2. Copied two fastq files from the workshop data folder to the Terra workspace bucket.
3. Created a Terra table called `metagenomics` with the four rows representing a 2x2 combination of samples and databases:

| entity:metagenomics_id | fastq1 | k2_db |
| --- | --- | --- |
| LongBoat-PlusPF | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Longboat-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst |
| Palmetto-PlusPF | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Palmetto-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst |
| LongBoat-MinusB | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Longboat-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz |
| Palmetto-MinusB | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Palmetto-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz |
4. Ran the `fastq_to_ubam` workflow on all rows of the `metagenomics` table, with `platform_name` = "ILLUMINA",
`library_name` = "1", `sample_name` = `this.metagenomics_id`, and `fastq_1` = `this.fastq1`.
5. Added the following rows to the Workspace Data table:
  - `workspace.kraken2_db_pluspf` = `gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst`
  - `workspace.kraken2_db_jhu_minusbacterial` = `gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz`
  - `workspace.krona_taxonomy_tab` = `gs://pathogen-public-dbs/v1/krona.taxonomy-20221213.tab.zst`
  - `workspace.ncbi_taxdump` = `gs://pathogen-public-dbs/v1/taxdump-20221213.tar.gz`
  - `workspace.spikein_db` = `gs://pathogen-public-dbs/v1/ercc_sdsi_spike-ins_20210809.fasta`
  - `workspace.trim_clip_db` = `gs://pathogen-public-dbs/v0/contaminants.clip_db.fasta`

The above steps do not take very long (a few minutes here and there) but were not worth spending the time on in this workshop.
But these steps are generalizable to any scenario or organism where you want to run your own fastq reads against our
kraken2-based classification pipeline.

## Walkthrough

### Clone the workspace

TO DO

### Run classify_single with two different kraken2 databases

Click on the Workflows tab on the top. This should lead to a list of analysis workflows that have already been preloaded into your
workspace. One of them is `classify_single`. Click on `classify_single`.

This will lead to a workflow launch page where you will need to set the parameters and inputs before launching your analyses.
Make sure to set the following:
- The `classify_single` "Version:" should be already set to `master`, but make sure it is set as such.
- "Run workflow(s) with inputs defined by data table" should be selected (not "file paths").
- "Step 1 -- Select root entity type:" should be set to `metagenomics`.
- "Step 2 -- SELECT DATA" -- click on this button and a data selector box will pop up. Check box all four rows of the `metagenomics` table so that we launch four jobs at the same time, one for each sample in the table. Hit the OK button on the lower right of the pop up box. This should return you to the workflow setup page which should now say that it will run on "4 selected metagenomicss".
- In the inputs table, we will need to populate the following required inputs:
  - `classify_single.reads_unmapped_bam` (required) should be set to `this.reads_ubam`
  - `classify_single.reference_fasta` (required) should be set to `workspace.ref_genome_ebov`

The resulting workflow launch page should look like this when you are ready:

### Evaluating results

## Other related resources