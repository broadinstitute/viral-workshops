# Viral *de novo* assembly

This is a walkthrough demonstrating *de novo* assembly workflows on the Terra cloud platform on Lassa virus Illumina data.

# Contents
{:.no_toc}

1. Table of Contents
{:toc}

## Data set

The data come from febrile patients with Lassa fever in Nigeria, where
patient blood was sequenced with a metagenomic (i.e. not amplified or enriched) RNA-seq laboratory approach.

The data, laboratory methods, and findings are described in [Siddle, et al, 2018](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6181183/)
and with metadata listed under NCBI Bioproject [PRJNA436552](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA436552):
 * LASV_NGA_2016_0409 ([SAMN08631573](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631573))
 * LASV_NGA_2016_0668 ([SAMN08631597](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631597))
 * LASV_NGA_2016_0759 ([SAMN08631618](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631618))
 * LASV_NGA_2016_0811 ([SAMN08631632](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631632))
 * LASV_NGA_2016_1423 ([SAMN08631658](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631658))
 * LASV_NGA_2016_1547 ([SAMN08631669](https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN08631669))

## Assembly pipeline

This exercise focuses on data from six samples: two producing high quality / near complete
assemblies, two producing partial medium-quality assemblies, and two producing poor-quality / unusable
assemblies. 

The exercise will use the Broad Viral Genomics group's viral *de novo* asssembly
pipeline ([Dockstore link](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/assemble_denovo:master?tab=info),
[GitHub source](https://github.com/broadinstitute/viral-pipelines/blob/master/pipes/WDL/workflows/assemble_denovo.wdl),
[Manual](https://viral-pipelines.readthedocs.io/en/latest/assemble_denovo.html)). 

In this exercise, the pipeline will run on the [Terra](https://terra.bio/) platform, however the pipeline is known
to work on other cloud platforms as well as via the command line using [miniWDL](https://miniwdl.readthedocs.io/en/latest/getting_started.html). The
underlying assembly methodology is described [here](https://viral-pipelines.readthedocs.io/en/latest/description.html).

Briefly, the `assemble_denovo` pipeline consists of the following steps:
1. Removal of reads originating from the host species (optional; performed only if depletion databases specified)
2. Read taxonomic filtration (optional, only performed if the `filter_to_taxon_db` parameter is specified)
3. Alignment-free PCR duplicate removal
4. Trimming of sequencing adapters ([Illumina adapters](https://support-docs.illumina.com/SHARE/AdapterSeq/1000000002694_17_illumina_adapter_sequences.pdf) in this case)
5. *de novo* assembly of reads into contigs
6. Scaffolding of contigs to user-provided reference genome(s), and selection of best reference if multiple are provided
7. gap-filling
8. Read-based polishing/refinement of draft genome

<img src="" alt="de novo assembly overview diagram"/>

## Terra workspace

For this exercise, we have created a [Terra workspace](https://app.terra.bio/#workspaces/veme-training/VEME%20NGS%202023) in advance and loaded in the sequencing read data and required reference databases. 
If you are starting from scratch on a new data set, what we did to populate these workspaces was:

1. Imported the following workflows from the Broad Institute Viral Genomics
[Dockstore collection](https://dockstore.org/organizations/BroadInstitute/collections/pgs):
`deplete_only`, `downsample`, and `assemble_denovo`.
2. Copied six `.bam` files from the workshop data folder to the Terra workspace bucket `raw_read_data/` subdirectory:
  - `LASV_NGA_2016_0409.ll2.cleaned.bam`
  - `LASV_NGA_2016_0668.ll4.cleaned.bam`
  - `LASV_NGA_2016_0759.ll1.cleaned.bam`
  - `LASV_NGA_2016_0811.ll3.cleaned.bam`
  - `LASV_NGA_2016_1423.cleaned.bam`
  - `LASV_NGA_2016_1547.ll4.cleaned.bam`
3. Copied geographically and temporally relevant reference genomes from the workshop data folder to the Terra workspace bucket `references/LASV` subdirectory:
  - `ref-lasv-BNI_Nig08_A19.fasta`
  - `ref-lasv-ISTH2376.fasta`
  - `ref-lasv-KGH_G502.fasta`
4. Created a Terra table called `de_novo_assembly` with six rows, each representing data for one sample:

| **entity:de_novo_assembly_id** | **raw_reads_unaligned_bam** |
|---|---|
| LASV_NGA_2016_0409 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_0409.ll2.bam |
| LASV_NGA_2016_0668 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_0668.ll4.bam |
| LASV_NGA_2016_0759 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_0759.ll1.bam |
| LASV_NGA_2016_0811 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_0811.ll3.bam |
| LASV_NGA_2016_1423 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_1423.bam |
| LASV_NGA_2016_1547 | gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/input_data/de_novo_assembly/raw_read_data/LASV_NGA_2016_1547.ll4.bam |

5. Ran the `deplete_only` workflow on all rows of the `de_novo_assembly` table, with:
  - `deplete_taxa.raw_reads_unmapped_bam` = `this.raw_reads_unaligned_bam`
  - `deplete_taxa.blastDbs` = `workspace.blastDbs`
  - `deplete_taxa.bwaDbs` = `workspace.bwaDbs`
6. Subsampled the reads for `LASV_NGA_2016_0759` to reduce the total data size, by running the `downsample` workflow, with:
  - `downsample_bams.reads_bam` = `this.cleaned_bam`
  - `downsample_bams.readCount` = `5000000`
  - `downsample_bams.deduplicateAfter` = `true`
  - (output) `downsample.downsampled_bam` = `this.cleaned_bam`
8. Added the following rows to the Workspace Data table:
  - `workspace.blastDbs` = `gs://pathogen-public-dbs/v0/GRCh37.68_ncRNA.fasta.zst, gs://pathogen-public-dbs/v0/hybsel_probe_adapters.fasta` (string list)
  - `workspace.bwaDbs` = `gs://pathogen-public-dbs/v0/hg19.bwa_idx.tar.zst`
  - `workspace.lasv_reference_scaffold_genomes` = `gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/references/LASV/ref-lasv-BNI_Nig08_A19.fasta, gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/references/LASV/ref-lasv-ISTH2376.fasta, gs://fc-d3199a88-7e13-433f-b77d-f62ef308d168/references/LASV/ref-lasv-KGH_G502.fasta` (string list)
  - `workspace.spikein_db` = `gs://pathogen-public-dbs/v0/ERCC_96_nopolyA.fasta`
  - `workspace.trim_clip_db` = `gs://pathogen-public-dbs/v0/contaminants.clip_db.fasta`

## Walkthrough

### Clone the workspace

We will use the same workspace that you have already cloned from the previous [Ebola read alignment exercise](alignment.md#clone-the-workspace).

### Run assemble_denovo

Click on the **Workflows** tab on the top. This should lead to a list of analysis workflows that have already been preloaded into your
workspace. One of them is `assemble_denovo`.

This will lead to a workflow configuration page where you will need to set parameters and inputs before launching your analysis.
Make sure to set the following:

- The `assemble_denovo` "Version:" should be already set to `master`, but make sure it is set as such.
- "Run workflow(s) with inputs defined by data table" should be selected (not "file paths").
- "Step 1 — Select root entity type:" should be set to `de_novo_assembly`.
- "Step 2 — **SELECT DATA**" — click on this button and a data selector box will pop up. Check box all six rows of the `de_novo_assembly` table so that we launch multiple assembly jobs at the same time, one for each sample in the table. After selecting the rows, click the **OK** button on the lower right of the pop up box. This should return you to the workflow setup page which should now say that it will run on "6 selected de_novo_assemblys" [sic].

<img width="80%" alt="input data selection" src="https://github.com/broadinstitute/viral-workshops/assets/53064/5743430f-46d9-4844-83bd-38ee8b0a480f">

- In the inputs table on the lower part of the page, the following required inputs will need to be set:
  - `assemble_denovo.reads_unmapped_bams` (required) should be set to `this.cleaned_bam`
  - `assemble_denovo.reference_genome_fasta` (required) should be set to `workspace.lasv_reference_scaffold_genomes`
  - `assemble_denovo.trim_clip_db` (required) should be set to `workspace.trim_clip_db`
  - `scaffold.min_unambig` should be set to `0.8`; this corresponds to the fraction of the genome that must be covered by unambiguous bases (i.e. not `N`s) for a successful assembly.
- Click the **SAVE** button after you've set all the inputs.

The resulting workflow launch page should look like this when you are ready:

<img width="80%" alt="image of workflow launch configuration" src="https://github.com/broadinstitute/viral-workshops/assets/53064/51711f0a-00c3-409b-91d9-9ef2ed034a75">

Click the **RUN ANALYSIS** button, which should be dark blue if all required inputs are properly set. 

Another modal dialog box will appear with an input box to enter a (human-readable) text description of the workflows jobs to be launched.
This is a helpful field to describe distinct or distinguishing features of the jobs being submitted, 
so jobs with various parameters or inputs subsets can be quickly located among other jobs that have been run.

<img width="461" max-width="80%" alt="workflow launch description modal" src="https://github.com/broadinstitute/viral-workshops/assets/53064/75070f7e-83ed-463f-b316-0a048f662acc">

Enter a description of your choosing, 
such as "de novo assembly of LASV genomes from six samples, with min_unambig passing threshold set to 0.8"

Click the **LAUNCH** button to start the compute jobs.

This will take you to a job submission status page for your newly launched workflow, 
showing six rows in the bottom table corresponding to the six jobs that have been launched.

<img width="80%" alt="Screenshot 2023-08-14 at 12 44 56" src="https://github.com/broadinstitute/viral-workshops/assets/53064/b6557013-79d2-448b-b99c-2bf4dd698432">

No connectivity or power is required at the client side during this time; the jobs will continue to run on Terra if you navigate away from the page or shutdown your computer.

The total runtime (real-world clock time) should be somewhat independent of whether you launched jobs on 1 or 1,000 samples, as the workflows are executed in parallel on separate cloud compute instances.

Some intermediate outputs are viewable before the full analysis completes, but it's often easier to wait for final results to be loaded into the table.

About 1 day after job completion, total cloud compute costs are displayed on this page (in USD). Prior to that, the run costs are listed as "N/A". 

### Wait for job completion

You will receive an email when each of your submissions complete (along with information about whether they succeeded or failed). 
Additionally, you can also click on the **JOB HISTORY** tab at the top of your workspace to check on the status of your analyses in progress.
When the `assemble_denovo` workflow jobs have finished running, you can move on to evaluating the results.
The job submission page for your submission under the Job History tab should look like this when the submissions are complete:

<img width="80%" alt="image of job history" src="https://github.com/broadinstitute/viral-workshops/assets/53064/68eea307-7030-4cd2-8763-127f798e542f">

Depending on some predictable and some unpredictable factors, the `assemble_denovo` jobs should complete within <20 minutes for input data of the sizes provided in this exercise.

## Evaluating results

You can examine the outputs and results of each step of each job via the Job History page, however, for large submissions, 
it is easier to view the saved top level outputs in the data table—in this case, the `de_novo_assembly` table. 

After the `assemble_denovo` jobs have completed, the `de_novo_assembly` table should have a number of additional output columns,
including assembly coverage plots for viewing read depth across the genome, `.fasta` sequence files, various intermediate output files, and metrics such as `assembly_length_unambiguous` and `mean_coverage`.

Among the many new columns, the following contain the outputs of the `assemble_denovo` workflow that are worth inspecting first:
 - `final_assembly_fasta` — contains sequence(s) assembled from the input reads (up to one per segment). The sequence(s) may contain ambiguous bases (`N`s) in regions of the genome lacking adequate read depth. All bases present represent coverage by actual reads and not bases imputed from references.
 - `aligned_bam` — contains reads mapped to the sequence of the final assembly ("mapped to self"), in [bam format](https://samtools.github.io/hts-specs/SAMv1.pdf).
 - `coverage_plot` - visualizes read depth as a function of genome location. Peaks indicate regions of high coverage; few reads mapped in regions with values near zero
 - `assembly_length` — the number of bases between the start and end position of the assembled sequence(s); this includes both known bases _and_ **ambiguous** bases (`N`s), and is not representative of the overall success of the assembly process
 - `assembly_length_unambiguous` — the number of distinct positions in the final assemgbly with unambigious bases (i.e. where the bases are known and not `N`). For a complete assembly, `assembly_length_unambiguous` will be close in value to the length of a known reference genome
 - `mean_coverage` — the number of reads mapped to the assembly, divided by the number of unambiguous bases

The metrics for the assemblies should be similar to those in the following table:

| entity:de_novo_assembly_id | assembly_length | assembly_length_unambiguous | mean_coverage      |
|----------------------------|-----------------|-----------------------------|--------------------|
| LASV_NGA_2016_0409         | 9056            | 5292                        | 55.897968197879855 |
| LASV_NGA_2016_0668         |                 |                             |                    |
| LASV_NGA_2016_0759         | 10551           | 10428                       | 161.0294758790636  |
| LASV_NGA_2016_0811         | 8334            | 2717                        | 1.8178545716342693 |
| LASV_NGA_2016_1423         | 10588           | 10588                       | 3051.3962032489612 |
| LASV_NGA_2016_1547         | 9289            | 5363                        | 5.262568629561847  |

Near-complete assemblies were produced for two samples, LASV_NGA_2016_1423 and LASV_NGA_2016_0759. Two produced partial assemblies, LASV_NGA_2016_0409 and LASV_NGA_2016_1547.
The remaining did not yield usable assemblies, though one, LASV_NGA_2016_0811, did have low-depth partial coverage across the genome.

Plots illustrating coverage depth for the assemblies are now available in PDF files listed in the `coverage_plot` column, and included here for reference:
 - [LASV_NGA_2016_0409](https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/LASV_NGA_2016_0409.ll2.coverage_plot.pdf)
 - [LASV_NGA_2016_0759](https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/LASV_NGA_2016_0759.ll1.cleaned.downsampled.dedup.mapped.coverage_plot.pdf)
 - [LASV_NGA_2016_0811](https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/LASV_NGA_2016_0811.ll3.coverage_plot.pdf)
 - [LASV_NGA_2016_1423](https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/LASV_NGA_2016_1423.coverage_plot.pdf)
 - [LASV_NGA_2016_1547](https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/LASV_NGA_2016_1547.ll4.coverage_plot.pdf)

The two colors shown each plot correspond to the two segments of the LASV genome (L, and S, respectively).

<img width="80%" alt="assembly coverage plot overview" src="https://github.com/broadinstitute/viral-workshops/blob/main/veme-ngs/de_novo_coverage_plots/coverage_overview.png">

### Inspecting results from this walkthrough

Recall that when the `assemble_denovo` workflow was configured, the `min_unambig` parameter was set to `0.8`. 
That value limits successful assemblies to those with ≥80% of bases known (i.e. not `N`).
Lowering the `min_unambig` threshold will make the assembly process more permissive in the assemblies deemed "successful."

Try lowering `min_unambig` based on the "failing" jobs observed during the first set of assembly jobs, and compare the resulting assemblies.


The columns shown or hidden for a data table can be configured by clicking the<img width="26" display="inline" style="top:0.4em;position:relative;" alt="column settings gear icon" src="https://github.com/broadinstitute/viral-workshops/assets/53064/d5123eb3-ccd3-4a9d-8a2a-4ef62ae9bd65">**SETTINGS** button above the table and selecting columns as desired.

<img width="761" alt="column settings button" src="https://github.com/broadinstitute/viral-workshops/assets/53064/6bbb1bc7-17e5-447e-bd12-184a67f16504">

<img width="822" alt="displayed column selector" src="https://github.com/broadinstitute/viral-workshops/assets/53064/355f570f-a9bf-4290-b09d-bbbb91ccbef2">

## Other related resources

See also [https://github.com/taylorpaisie/VEME_2023_NGS_Denovo_assembly](https://github.com/taylorpaisie/VEME_2023_NGS_Denovo_assembly)
