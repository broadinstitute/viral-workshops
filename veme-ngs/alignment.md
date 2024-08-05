# Viral read alignment, variant calling, and consensus calling

This is a walkthrough demonstrating alignment, variant calling, and consensus calling
workflows on the Terra cloud platform on Ebola virus Illumina data.

# Contents
{:.no_toc}

1. Table of Contents
{:toc}

## Description of data set

The data comes from febrile Ebola patients in Sierra Leone.
The data and findings are described in [Park, et al, 2015](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4503805/)
and deposited in NCBI SRA and Genbank under [PRJNA257197](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA257197).

This exercise focuses on data from four samples (SRR1972917, SRR1972918, SRR1972919, SRR1972920) of a wide range
of sequencing quality (SRR1972920 is relatively poor coverage with much of the genome uncovered, SRR1972918 is very deeply
covered). Each is 101bp paired end Illumina data sequenced from libraries generated on patient blood samples via metagenomic
RNA-seq laboratory approaches. All patients were sampled in 2014 from Sierra Leone, and all genomes belong to the SL3
clade of the Makona variant of Zaire ebolavirus. This exercise will utilize the *de facto* standard Makona C15 reference
genome (KJ660346.2, March 2014, Guinea) for alignments and variant calling.

## Description of workflows

The exercise will utilize workflows from the Broad Viral Genomics group.
This will include the read alignment pipeline
([Dockstore link](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/align_and_plot:master?tab=info),
[GitHub source](https://github.com/broadinstitute/viral-pipelines/blob/master/pipes/WDL/workflows/align_and_plot.wdl),
[Manual](https://viral-pipelines.readthedocs.io/en/latest/align_and_plot.html))
and the reference based consensus calling pipeline
([Dockstore link](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/assemble_refbased:master?tab=info),
[GitHub source](https://github.com/broadinstitute/viral-pipelines/blob/master/pipes/WDL/workflows/assemble_refbased.wdl),
[Manual](https://viral-pipelines.readthedocs.io/en/latest/assemble_refbased.html))
and practice execution on the [Terra](https://terra.bio/) platform, but these pipelines are known
to work on other cloud platforms as well as on the command line using miniWDL.

The `align_and_plot` workflow simply aligns reads to a reference (using minimap2, bwa, or novoalign),
creates coverage plots, and calculates various metrics of interest (number of aligned reads, etc).

The `assemble_refbased` workflow performs the same alignment to a reference, optionally trims the alignments
for primers if provided a bed file (for sequencing protocols involving PCR amplification followed by tagmentation),
produces plots and metrics, and calls a consensus assembly and intrahost variants.

## Terra workspace setup

For simplicity, we have already loaded in the read data and the reference genomes. If you are starting from scratch on a new
organism, what we did to populate these workspaces was:

1. Imported the following workflows from the Broad Institute Viral Genomics
[Dockstore collection](https://dockstore.org/organizations/BroadInstitute/collections/pgs):
`fetch_sra_to_bam`, `fetch_annotations`, `align_and_plot`, `assemble_refbased`.
2. Created a Terra table called `ebov` with the four SRA accessions:

| entity:ebov_id | sra_accession | biosample_accession |
| --- | --- | --- |
| G5723.1 | SRR1972917 | SAMN03254208 |
| G5731.1 | SRR1972918 | SAMN03254209 |
| G5732.1 | SRR1972919 | SAMN03254210 |
| G5735.2 | SRR1972920 | SAMN03254213 |

3. Ran the `fetch_sra_to_bam` workflow on all rows of the `ebov` table to download reads from all four SRA accessions,
populating more columns of the table with raw reads and basic run/sample metadata.
4. Ran the `fetch_annotations` workflow (on file paths, not data tables) to download the reference genome (KJ660346.2)
and manually added a pointer to the output fasta file in the Workspace Data table as `workspace.ref_genome_ebov`.

The above steps do not take very long (a few minutes here and there) but were not worth spending the time on in this workshop.
But these steps are generalizable to any scenario or organism where you want to align SRA reads against a Genbank reference genome.

## Analysis walkthrough

### Clone the workspace

A workspace for these exercises has been created in advance, and contains the required input data organized into distinct tables.
The tables can be explored from the "[**Data**](https://app.terra.bio/#workspaces/veme-training/VEME%20NGS/data)"
tab.

Before beginning the exercise, the pre-made workspace will be copied to a "clone" that will be yours to use for these exercises. 
Using a cloned workspace will ensure that the compute jobs and their outputs you see are yours alone.

<img width="40%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/7ee1527f-713e-4b27-88b0-bf47cd266278">

 - Navigate to the [workspace for this workshop](https://app.terra.bio/#workspaces/veme-training/VEME%20NGS)
 - Expand the workspace actions menu by clicking the round button with three dots (vertical ellipsis) in the upper right corner
 - Select **Clone**
 - In the modal dialog box that appears: 
  - Give the new (clone) workspace a descriptive `Workspace name` -- for the purposes of this workshop, include your initials or name in order to uniquely identify it (e.g. "VEME NGS 2024 Jane Smith").
  - Set the `Billing project` to "veme-training" (if it isn't already).
  - Leave the `Bucket location` and `Description` as their default values.
  - **Do not check** the "workspace will have protected data" box, and **do not** select an Authorization domain -- these will (intentionally) make data access much more difficult, and selecting these options is unnecessary for most work on Terra, especially training workshops.

<img width="40%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/122baba8-432c-482a-b4c5-507fc7f5e6d0">


### Run align_and_plot

Click on the Workflows tab on the top. This should lead to a list of analysis workflows that have already been preloaded into your
workspace. One of them is `align_and_plot`. Click on `align_and_plot`.

This will lead to a workflow launch page where you will need to set the parameters and inputs before launching your analyses.
Make sure to set the following:
 - The `align_and_plot` "Version:" should be already set to `master`, but make sure it is set as such.
 - "Run workflow(s) with inputs defined by data table" should be selected (not "file paths").
 - "Step 1 -- Select root entity type:" should be set to `ebov`.
 - "Step 2 -- SELECT DATA" -- click on this button and a data selector box will pop up. Check box all four rows of the `ebov` table so that we launch four jobs at the same time, one for each sample in the table. Hit the OK button on the lower right of the pop up box. This should return you to the workflow setup page which should now say that it will run on "4 selected ebovs".
 - In the inputs table, we will need to populate the following required inputs:
   - `align.reads_unmapped_bam` (required) should be set to `this.reads_ubam`
   - `align.reference_fasta` (required) should be set to `workspace.ref_genome_ebov`
 - Click the SAVE btuton after you've set all the inputs.

The resulting workflow launch page should look like this when you are ready:

<img width="80%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/7885694a-d4ac-4ada-a904-1b108e8d53f5">

Click "RUN ANALYSIS" (which should be dark blue if you've filled in all inputs properly). This will take you to a job submission
status page for your newly launched workflow, showing four rows in the bottom table corresponding to the four jobs that have been launched.

### Run assemble_refbased

Click on the Workflows tab on the top. This should lead to a list of analysis workflows that have already been preloaded into your
workspace. One of them is `assemble_refbased`. Click on `assemble_refbased`.

This will lead to a workflow launch page where you will need to set the parameters and inputs before launching your analyses.
Make sure to set the following:
 - The `assemble_refbased` "Version:" should be already set to `master`, but make sure it is set as such.
 - "Run workflow(s) with inputs defined by data table" should be selected (not "file paths").
 - "Step 1 -- Select root entity type:" should be set to `ebov`.
 - "Step 2 -- SELECT DATA" -- click on this button and a data selector box will pop up. Check box all four rows of the `ebov` table so that we launch four jobs at the same time, one for each sample in the table. Hit the OK button on the lower right of the pop up box. This should return you to the workflow setup page which should now say that it will run on "4 selected ebovs".
 - In the inputs table, we will need to populate the following inputs:
   - `assemble_refbased.reads_unmapped_bams` (required) should be set to `this.reads_ubam`
   - `assemble_refbased.reference_fasta` (required) should be set to `workspace.ref_genome_ebov`
   - `assemble_refbased.sample_name` (optional) could be set to `this.ebov_id` to make for cleaner filenames and fasta headers, if desired

The resulting workflow launch page should look like this when you are ready (optional input not shown here, as it is a page or two down below):

<img width="80%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/1d5db305-edc2-4242-95e0-1ee9e58229ea">

Click "RUN ANALYSIS" (which should be dark blue if you've filled in all inputs properly). This will take you to a job submission
status page for your newly launched workflow, showing four rows in the bottom table corresponding to the four jobs that have been launched.

If you are running this workflow on PCR amplicon sequencing libraries, you would also need to supply the following inputs (*these do not apply to this workshop's data set, which is metagenomic*):
 - `assemble_refbased.trim_coords_bed` should be set to an input file (BED format) that describes the primer set used for library construction. If this differs for each sample, it is recommended to load this into the Terra data table. This will need to be provided by the laboratory team that sequenced these samples. Default value on empty input is not to perform any primer trimming. Failure to provide this input on PCR amplicon libraries may result in erroneous reference allele calls throughout the genome.
 - `assemble_refbased.skip_mark_dupes` should be set to `true` for PCR amplicon libraries (since all reads are intentionally PCR duplicates, we do not want to remove them). Default value is false.
 - `assemble_refbased.min_coverage` should be set to at least `20` or higher for PCR amplicon libraries (default value is `3` which is only appropriate for metagenomic libraries). Any positions in the genome with less than this amount of aligned coverage (after primer trimming and after duplicate removal, unless duplicate removal is skipped) will be assigned an `N` in the output fasta.

### Wait for job completion

You will receive an email when each of your submissions complete (along with information about whether they succeeded or failed).
Additionally, you can also click on the JOB HISTORY tab at the top of your workspace to check on the status of your analyses in progress.
When both `assemble_refbased` and `align_and_plot` are complete, you can move on to evaluating the results. The Job History tab should
look like this when the submissions are complete:

<img width="80%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/c0cf3212-9f3f-4b55-8bf6-943561230852">

Depending on some predictable and some unpredictable factors, the `align_and_plot` jobs should complete within 15 minutes and the
`assemble_refbased` within 30, but they may take much longer (2-3x longer). No user intervention is required while you await results,
and no connectivity or power is required at the client side during this time. The runtime should be somewhat independent of whether
you launched jobs on 1 or 1,000 samples.

## Evaluating results

You can examine the outputs and results of each step of each job via the Job History page, however, for large submissions, it is easier
to view the saved top level outputs in the data table--in this case, the `ebov` table. The `ebov` table now has a number of additional output
columns, including aligned BAM files, coverage plots, consensus genomes (FASTA), variants (VCF), and various numeric counts and metrics.

#### Metrics

`align_and_plot` produces a few key outputs of interest:
 - Aligned reads:
  - All reads (aligned and unaligned): `aligned_bam` (BAM), `aligned_bam_idx` (BAI)
  - Aligned, properly paired, deduplicated reads only (usually much smaller files than all reads): `aligned_only_reads_bam`, `aligned_only_reads_bam_idx`
 - Metrics and counts:
  - Read counts: input (`reads_provided`), aligned (`reads_aligned`), properly paired read pairs (`read_pairs_aligned`)
  - Base counts: base-pairs aligned (`bases_aligned`), reference genome length (`reference_length`)
  - Base counts divided by reference genome length: `mean_coverage`
  - FastQC plots of aligned-only reads: `aligned_only_reads_fastqc`
  - Coverage plots: `coverage_plot` (PDF), `coverage_tsv` (tab delimited text)

Typically the aligned read counts and coverage plots are looked at first.

`assemble_refbased` produces a few key outputs of interest:
 - Consensus genome and metrics: `assembly_fasta` (FASTA), `assembly_length`, `assembly_length_unambiguous`, `assembly_mean_coverage`, `align_to_self_merged_coverage_plot` (PDF)
 - Aligned reads to reference: `align_to_ref_merged_aligned_trimmed_only_bam` (BAM), `align_to_ref_merged_coverage_plot` (PDF), `align_to_ref_isnvs_vcf` (VCF)

Typically, the `assembly_fasta` is used for most downstream analyses (phylogenetic, typing, species-specific characterization) as well as data release and sharing. The other outputs listed above are used to evaluate sample data quality and filter which assemblies are included in downstream analysis.

#### Coverage plot outputs

The numeric counts and metrics give a holistic summary of the sequencing performance of any sample, but inspecting coverage plots can reveal any biases or issues at certain parts of the target genome and how much of that genome was recovered. Coverage plots are generated by `assemble_refbased` in two output files: a visual plot (PDF format) is provided in the `align_to_ref_merged_coverage_plot` output column. A two-column tab-delimited table indicating read depth coverage at each genomic position is provided in the `align_to_ref_merged_coverage_tsv` output column -- this table is used to generate the PDF plot, and can be used to regenerate such plots using your preferred plotting software. The plots provided by this pipeline are after alignment, primer trimming (optional/if applicable), and PCR deduplication (unless disabled), and should exactly match the alignments in the aligned BAM file `align_to_ref_merged_aligned_trimmed_only_bam`.

You can click on the live links for any file element in the Terra data table and download them, or preview them in your browser. As an example, click on the `SRR1972917.coverage_plot.pdf` live link in the `coverage_plot` column of the `G5723.1` row of the `ebov` data table. This will open a "File Details" box where you can access this file three different ways:
1. Click the blue DOWNLOAD button to download it to your computer. You can then open the downloaded file in a browser to view.
2. If you have the [gcloud API CLI](https://cloud.google.com/cli?hl=en) installed in a command-line environment, and copy and paste the `gcloud storage cp` command to your terminal, the file will be downloaded that way.
3. If you click the "View this file in the Google Cloud Storage Browser", an external page will be opened in the web browser showing the file where it resites in its Google Storage bucket. This directory will contain many other files, but look for the link to the file you were looking for originally (`SRR1972917.coverage_plot.pdf`), and click it. An "Object details" page will open with information and several links for this particular file. Clicking the "Authenticated URL" link will open the krona plot in your web browser.

Repeat the above steps for all four results to open in separate tabs.

Below are what the outputs should look like for our four EBOV genomes. The x-axis coordinates match the full reference genome provided to `assemble_refbased`. The y-axis is autoscaled and differs for each plot (by orders of magnitude in this case). You can observe that SRR1972918 has extremely high coverage, SRR1972920 has extremely poor coverage, and all samples struggled with some difficult sequence content around reference position 2400.

<img width="35%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/a267d6e6-7971-4601-9482-3ec07b0600e8">
<img width="35%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/da3a5b2b-bf99-4ded-a017-cf6cda10a3ee">
<img width="35%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/d0f2ef3c-32f3-4797-a916-06542f0da096">
<img width="35%" alt="image" src="https://github.com/broadinstitute/viral-workshops/assets/8513746/9af86c3f-b246-4ce4-b4eb-b5d87d9ba5b6">

## Other related resources

See also:
 - For CLI methods on the same data set for this workshop, see [Taylor Paisie's VEME notes](https://taylorpaisie.github.io/VEME_2024_NGS_Variant_Calling/)
 - The [TheiaCoV workflows for viral genomics](https://public-health-viral-genomics-theiagen.readthedocs.io/en/latest/overview.html) are highly popular in public health labs and come with a lot of documentation, training, and support. This is the recommended starting point for the most common microbial genomics analysis needs. The reference-based analysis workflows work well for a large range of viral taxa (they also have bacterial and eukaryotic workflows) and accept inputs for paired and single end Illumina data as well as ONT and ClearLabs data. They do not currently have a *de novo* assembly workflow, so this training utilizes the Broad Institute's *de novo* workflows instead.
