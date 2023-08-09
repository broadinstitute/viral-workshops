# Viral de novo assembly

This is a walkthrough demonstrating *de novo* assembly workflows on the Terra cloud platform on Lassa virus Illumina data.

## Data set

The data comes from febrile Lassa fever patients in Nigeria, where
patient blood was sequenced with metagenomic RNA-seq laboratory approaches.
The data and findings are described in [Siddle, et al, 2018](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6181183/)
and deposited in NCBI SRA and Genbank under [PRJNA436552](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA436552).

This exercise focuses on data from six samples: two producing high quality / near complete
assemblies, two producing medium-quality assemblies, and two producing poor-quality / unusable
assemblies. The genomes span at three different phylogenetic clades of LASV.

## Assembly pipeline

The exercise will utilize the Broad Viral Genomics group's viral *de novo* asssembly
pipeline ([Dockstore link](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/assemble_denovo:master?tab=info),
[GitHub source](https://github.com/broadinstitute/viral-pipelines/blob/master/pipes/WDL/workflows/assemble_denovo.wdl),
[Manual](https://viral-pipelines.readthedocs.io/en/latest/assemble_denovo.html)) and
practice execution on the [Terra](https://terra.bio/) platform, but this pipeline is known
to work on other cloud platforms as well as on the command line using miniWDL. The
underlying assembly methodology is described [here](https://viral-pipelines.readthedocs.io/en/latest/description.html).

Briefly, the `assemble_denovo` pipeline consists of the following steps:
1. Read dehosting (optional, only if depletion databases specified)
2. Read taxonomic filtration (optional, only if filter_to_taxon_db specified)
3. Alignment-free PCR duplicate removal
4. Adapter trimming and *de novo* assembly of reads into contigs
5. Scaffolding of contigs to user-provided reference genome(s) (and selection of best reference if multiple are provided) and gap-filling
6. Read-based polishing/refinement of draft genome

## Terra workspace

Describe what's in the tables and what workflows are pre-loaded.

## Walkthrough

### Clone the workspace

### Run assemble_denovo


## Other related resources

See also https://github.com/taylorpaisie/VEME_2023_NGS_Denovo_assembly
