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

## Terra workspace

Describe what's in the tables and what workflows are pre-loaded.

## Walkthrough

### Clone the workspace

### Run align_and_plot

### Run assemble_refbased

### Evaluating results

## Other related resources

See also https://github.com/taylorpaisie/VEME_NGS_variant_calling