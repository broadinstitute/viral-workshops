# Viral read alignment and variant calling

TO DO - examples with EBOV genomes

# Viral read alignment, variant calling, and consensus calling

This is a walkthrough demonstrating alignment, variant calling, and consensus calling
workflows on the Terra cloud platform on Ebola virus Illumina data.

## Data set

The data comes from febrile Ebola patients in Sierra Leone, where
patient blood was sequenced with metagenomic RNA-seq laboratory approaches.
The data and findings are described in [Gire, et al, 2014](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4431643/)
and deposited in NCBI SRA and Genbank under [PRJNA257197](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA257197).

This exercise focuses on data from TBD samples: MORE INFO HERE.

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
4. Ran the `fetch_annotations` workflow (on file paths, not data tables) to download the reference genome (Ebola Makona C15)
and manually added a pointer to the output fasta file in the Workspace Data table as `workspace.ref_genome_ebov`.

The above steps do not take very long (a few minutes here and there) but were not worth spending the time on in this workshop.
But these steps are generalizable to any scenario or organism where you want to align SRA reads against a Genbank reference genome.

## Walkthrough

### Clone the workspace

### Run align_and_plot

### Run assemble_refbased

### Evaluating results

## Other related resources

The [TheiaCoV workflows for viral genomics](https://public-health-viral-genomics-theiagen.readthedocs.io/en/latest/overview.html) are highly
popular in public health labs and come with a lot of documentation, training, and support. This is the recommended starting point for the most common
microbial genomics analysis needs. The reference-based analysis workflows work well for a large range of viral taxa (they also have bacterial
and eukaryotic workflows) and accept inputs for paired and single end Illumina data as well as ONT and ClearLabs data. They do not currently have
a *de novo* assembly workflow, so this training utilizes the Broad Institute's *de novo* workflows instead.

For CLI approaches on the same dataset for this workshop, see https://github.com/taylorpaisie/VEME_NGS_variant_calling
