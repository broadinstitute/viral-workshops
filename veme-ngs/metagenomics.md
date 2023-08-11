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

| entity:metagenomics_id | sample | fastq1 | k2_db |
| --- | --- | --- | --- |
| LongBoat-PlusPF | LongBoat | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Longboat-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst |
| Palmetto-PlusPF | Palmetto | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Palmetto-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst |
| LongBoat-MinusB | LongBoat | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Longboat-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz |
| Palmetto-MinusB | Palmetto | gs://fc-087bd768-59d8-44d6-840c-db53ee977ccd/input_data/metagenomics/Palmetto-250k.fastq.gz | gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz |

4. Ran the `fastq_to_ubam` workflow on all rows of the `metagenomics` table, with `platform_name` = "ILLUMINA",
`library_name` = "1", `sample_name` = `this.sample`, and `fastq_1` = `this.fastq1`.
5. Added the following rows to the Workspace Data table:
  - `workspace.kraken2_db_pluspf` = `gs://pathogen-public-dbs/jhu/k2_pluspf_20221209.tar.zst`
  - `workspace.kraken2_db_jhu_minusbacterial` = `gs://pathogen-public-dbs/jhu/k2_minusb_20230605.tar.gz`
  - `workspace.krona_taxonomy_tab` = `gs://pathogen-public-dbs/v1/krona.taxonomy-20221213.tab.zst`
  - `workspace.ncbi_taxdump` = `gs://pathogen-public-dbs/v1/taxdump-20221213.tar.gz`
  - `workspace.spikein_db` = `gs://pathogen-public-dbs/v1/ercc_spike-ins-20170523.fa`
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
  - `classify_single.kraken2_db_tgz` (required) should be set to `this.k2_db`
  - `classify_single.krona_taxonomy_db_kraken2_tgz` (required) should be set to `workspace.krona_taxonomy_tab`
  - `classify_single.ncbi_taxdump_tgz` (required) should be set to `workspace.ncbi_taxdump`
  - `classify_single.reads_bams` (required) should be set to `this.unmapped_bam`
  - `classify_single.spikein_db` (required) should be set to `workspace.spikein_db`
  - `classify_single.trim_clip_db` (required) should be set to `workspace.trim_clip_db`
- Click the SAVE button after you've set all the inputs.

The resulting workflow launch page should look like this when you are ready:

<img width="80%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/e4ac4f5a-cbc3-4247-8d39-3f455cea6432">

Click "RUN ANALYSIS" (which should be dark blue if you've filled in all inputs properly). This will take you to a job submission
status page for your newly launched workflow, showing four rows in the bottom table corresponding to the four jobs that have been launched.

### Wait for job completion

You will receive an email when each of your submissions complete (along with information about whether they succeeded or failed). Additionally, you can also click on the JOB HISTORY tab at the top of your workspace to check on the status of your analyses in progress. When `classify_single` is complete, you can move on to evaluating the results. The job submission page for your submission under the Job History tab should look like this when the submissions are complete:

<img width="80%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/42ad9346-dd59-463a-bdf1-b60677ee03e0">

TO DO -- re-do this screenshot for four runs instead of three (oops)

Depending on some predictable and some unpredictable factors, the `classify_single` jobs should complete within about 30 minutes for the MinusB kraken2 databases and about 60 minutes for the PlusPF databases, but may take longer. No user intervention is required while you await results, and no connectivity or power is required at the client side during this time. The runtime should be somewhat independent of whether you launched jobs on 1 or 1,000 samples. Some intermediate outputs are viewable before the full analysis completes, but it's often easier to wait for final results to be loaded into the table.

About 1 day after job completion, total cloud compute costs are displayed on this page (in USD). Prior to that, the run costs are listed as "N/A". Kraken2 analysis costs and runtime tend to scale more with the size of the kraken2 database than the size of the input sequencing data (unless it is an extremely large volume of sequencing data).

### Evaluating results

You can examine the outputs and results of each step of each job via the Job History page, however, for large submissions, it is easier to view the saved top level outputs in the data table--in this case, the `metagenomics` table. The `metagenomics` table now has a number of additional output columns, including krona plots for viewing metagenomics results, text summary files, subsetted/filtered read sets, fastqc plots on subsetted reads, and viral *de novo* contigs.

### Kraken and Krona outputs

TO DO: how to dive into these, the text summary file and the krona html plot

Krona plots of the arboviral data, two different databases:
- [LongBoat reads, MinusB database](krona/LongBoat.kraken2-MinusB.krona.html)
- [LongBoat reads, PlusPF database](krona/LongBoat.kraken2-PlusPF.krona.html)
- [Palmetto reads, MinusB database](krona/Palmetto.kraken2-MinusB.krona.html)
- [Palmetto reads, PlusPF database](krona/Palmetto.kraken2-PlusPF.krona.html)

Krona plots from the previously used [Ebola](alignment.md) and [Lassa](denovo.md) example data against the JHU PlusPF database:
- [EBOV G5723.1](krona/SRR1972917.kraken2.krona.html)
- [EBOV G5731.1](krona/SRR1972918.kraken2.krona.html)
- [EBOV G5732.1](krona/SRR1972919.kraken2.krona.html)
- [EBOV G5735.2](krona/SRR1972920.kraken2.krona.html)
- [LASV_NGA_2016_0409](krona/LASV_NGA_2016_0409.ll2.kraken2.krona.html)
- [LASV_NGA_2016_0668](krona/LASV_NGA_2016_0668.ll4.kraken2.krona.html)
- [LASV_NGA_2016_0759](TBD)
- [LASV_NGA_2016_0811](krona/LASV_NGA_2016_0811.ll3.kraken2.krona.html)
- [LASV_NGA_2016_1423](krona/LASV_NGA_2016_1423.kraken2.krona.html)
- [LASV_NGA_2016_1547](TBD)

Other example krona plots from outside data sets:
- Nigerian unknown fatal fever, 2015 ([DNAsed](krona/NGA_FUO_Dnased.krona-report.html), [non-DNAsed](krona/NGA_FUO.all.krona-report.html))
- Water/non-template-controls from [Broad Institute](krona/Broad_NTC.krona-report.html), [Universite Cheikh Anta Diop](krona/UCAD_W1.krona-report.html) -- NTCs should be run in every metagenomic sequencing batch and closely examined
- Non-metagenomic examples of krona as a generalized heirarchical composition visualization tool: [nutritional composition](krona/Example%20-%20Granola.html), [MacOS user directory](krona/Example%20-%20File%20System.html)
- Other LASV patient samples [well detected](krona/A4.lA4.krona-report.html) (but note how many reads LCA to the family level), [poorly detected](krona/LASV-B2.lB2.krona-report.html) (this had a lot of LASV reads but was genetically distant from the kraken database, note the size of the "no hits")

### Subsetted read sets

Among other outputs, kraken2 will classify every read in your input data--that is, it will assign an NCBI taxid to every read you gave it. Our pipeline additionally uses this output to create two subsetted read sets of your input data:

- Dehosted reads: all reads from input that did *not* classify as `Vertebrata` or lower. This includes all non-vertebrate reads plus unclassified reads and those that classified at a higher taxonomic rank than the subphylum level. Reads are contained in the `cleaned_reads_unaligned_bam` output, with the numeric count provided in `read_counts_depleted` and the FastQC plot provided in `cleaned_fastqc`.
- Deduplicated acellular reads: all reads from input that did *not* classify as `Vertebrata`, `other sequences` (synthetic constructs), or `Bacteria` and then PCR deduplicated via an alignment-free approach. Reads are contained in the `deduplicated_reads_unaligned` output, with the numeric count provided in `read_counts_dedup`.

The dehosted reads are typically the data set you will submit to SRA/ENA for public data release and these can be used for downstream analyses whether [alignment-based](alignment.md) or [assembly-based](denovo.md) (in the latter case, you can skip any dehosting steps to save time and cost, since it has already been done here).

A FastQC plot is generated on this subset as well, because we have found over the years that working with metagenomic reads from direct patient specimens sometimes exhibits different RNA degradation/quality between host nucleic acids and RNA viral nucleic acids within the same sample--BioAnalyzer/TapeStation outputs and FastQC plots on the total raw data may obscure this difference if it exists. Our team does not always proactively look at these plots unless problems are encountered, but they are easy to generate and helpful if needed.

The acellular reads are often the "target" data of interest (unless you are interested in the bacteria) and are often a very small fraction of the input data. These subsetted BAM files are often small enough to download and work with in local analysis or visual tools, and would be the appropriate input SPAdes and other focused analysis steps.

### Viral contigs

The `classify_single` workflow will additionally take the subset of reads classified as *acellular* (all viral and unclassified reads, typically representing a small minority of the input data) and perform *de novo* assembly via SPAdes. The resulting contigs are provided in the `contigs_fasta` output column of the `metagenomics` table. You can download these fasta files from the table view--they should not be particularly large files (in this workshop's data set, all of these files are less than 0.5MB).

For highly diverse viral taxa, k-mer based read classification will have sensitivity limitations, especially when utilizing RefSeq-only databases and/or if the full diversity of the species is not captured well in INSDC at all. As a practical example, Lassa virus (LASV) is about 70% conserved at the nucleotide level across the species--with an average of 1 SNP every 3bp, no k-mer-based method will match these unless a close enough genome is represented in the database. Default JHU kraken(2) databases include only one representative genome per viral species (the RefSeq genome), so the options include either 1) building a custom database with more viral diversity (`gs://pathogen-public-dbs/v1/kraken2-broad-20200505.tar.zst` is an example) or utilizing a different detection approach.

Utilizing *de novo* contigs instead of raw reads for detection provides more statistical power per sequence for distant matches via BLAST or BLAST-like approaches. This workshop does not go into detail on how to employ these approaches, however the most common and simple approach that researchers will take as a next step for investigation is to run the contigs through [NCBI BLAST](https://blast.ncbi.nlm.nih.gov/) against `nt` (blastn) or `nr` (blastx).

## Other related resources

TO DO: links to Carla's stuff
