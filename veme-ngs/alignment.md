# Viral read alignment and variant calling

TO DO - examples with EBOV genomes

# Viral read alignment, variant calling, and consensus calling

This is a walkthrough demonstrating alignment, variant calling, and consensus calling
workflows on the Terra cloud platform on Ebola virus Illumina data.

## Data set

The data comes from febrile Ebola patients in Sierra Leone.
The data and findings are described in [Park, et al, 2015](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4503805/)
and deposited in NCBI SRA and Genbank under [PRJNA257197](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA257197).

This exercise focuses on data from four samples (SRR1972917, SRR1972918, SRR1972919, SRR1972920) of a wide range
of sequencing quality (SRR1972920 is relatively poor coverage with much of the genome uncovered, SRR1972918 is very deeply
covered). Each is 101bp paired end Illumina data sequenced from libraries generated on patient blood samples via metagenomic
RNA-seq laboratory approaches. All patients were sampled in 2014 from Sierra Leone, and all genomes belong to the SL3
clade of the Makona variant of Zaire ebolavirus. This exercise will utilize the *de facto* standard Makona C15 reference
genome (KJ660346.2, March 2014, Guinea) for alignments and variant calling.

## Workflows

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

## Terra workspace

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

## Walkthrough

### Clone the workspace

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

### Evaluating results

#### Coverage plot outputs

![coverage plot SRR1972917](coverage-SRR1972917.pdf)

![coverage plot SRR1972918](coverage-SRR1972918.pdf)

![coverage plot SRR1972919](coverage-SRR1972919.pdf)

![coverage plot SRR1972920](coverage-SRR1972920.pdf)


## Other related resources

The [TheiaCoV workflows for viral genomics](https://public-health-viral-genomics-theiagen.readthedocs.io/en/latest/overview.html) are highly
popular in public health labs and come with a lot of documentation, training, and support. This is the recommended starting point for the most common
microbial genomics analysis needs. The reference-based analysis workflows work well for a large range of viral taxa (they also have bacterial
and eukaryotic workflows) and accept inputs for paired and single end Illumina data as well as ONT and ClearLabs data. They do not currently have
a *de novo* assembly workflow, so this training utilizes the Broad Institute's *de novo* workflows instead.

For CLI approaches on the same dataset for this workshop, see https://github.com/taylorpaisie/VEME_NGS_variant_calling
