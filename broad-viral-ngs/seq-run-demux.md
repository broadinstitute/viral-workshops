# Sequencing run demultiplexing

This is a walkthrough demonstrating demultiplexing of data from a viral sequencing run of pooled sequencing libraries.

# Contents
{:.no_toc}

1. Table of Contents
{:toc}

## Inspect and upload the sample sheet for the run to be demultiplexed

View the sample sheet file provided, called `SampleSheet_reprep_06_ss2.tsv`[^1].

### Sample sheet columns required for demultiplexing

For the _demux\_deplete_ workflow, a sample sheet is required to supply the sample-specific index information required for assigning reads to output files for individual samples in pool of sequencing libraries. The sample sheet is formatted as a text file with tab-separated values ([tsv](https://en.wikipedia.org/wiki/Tab-separated_values)). 

The sample sheet must have the following required columns:

| sample | barcode_1 | barcode_2 | library_id_per_sample |
|--------|-----------|-----------|-----------------------|
|        |           |           |                       |

 - `sample`: name of the sample, often a reference to the internal identifier for the original biological material
 - `barcode_1`: the [i7 index](https://support.illumina.com/content/dam/illumina-support/documents/documentation/system_documentation/miseq/indexed-sequencing-overview-guide-15057455-08.pdf) for read 1 (dual-index paired-end sequencing, or single-index sequencing)
 - `barcode_2`: the i5 index for read 2 (dual-index paired-end sequencing)
 - `library_id_per_sample`: an identifier for a library prepared _from_ a physical sample. This may also include additional library preparation-related information, such as microtiter well number, the identifier of a synthetic spiked-in control (ex. [ERCC RNA](https://www.nist.gov/system/files/documents/2016/09/26/2374_coa_2013.pdf)), or descriptors of the library preparation protocol.

If a sequencing run includes the same pool of libraries across multiple flowcell lanes, _demux\_deplete_ will output a single file for a given `sample` name, that contains multiple read groups ([sam/bam/cram](https://samtools.github.io/hts-specs/SAMv1.pdf) `@RG` lines), one for each lane. Each read group is identified by a unique combination of information of the flowcell ID, the library ID, and the lane number (stored as the `LB` value in a sam or bam-formatted file).

### Additional sample sheet columns helpful for data submission

A number of additional columns can be included with metadata helpful for downstream processes and the creation of the files necessary for submission of data to public databases (i.e. NCBI [BioSample](https://www.ncbi.nlm.nih.gov/biosample) and [SRA](https://www.ncbi.nlm.nih.gov/sra)):

| library_strategy | library_source | library_selection |
|------------------|----------------|-------------------|
|                  |                |                   |

 - `library_strategy`: the type of library preparation used (ex. `AMPLICON`, `RNA-Seq`, `WGS`) **_Controlled vocabularity_**
 - `library_source`: the source material (ex. `VIRAL RNA`, `GENOMIC`, `SYNTHETIC`) **_Controlled vocabularity_**
 - `library_selection`: the selection, enrichment, or screening process used (ex. `PCR`, `RANDOM`, `RT-PCR`) **_Controlled vocabulary_**
 - `design_description`: free text briefly describing methods used (ex. `RandomPrimer-SSIV_NexteraXT`, `RandomPrimer-SSIV_ARTICv3_NexteraFlex-Enrichment`)

For `library_strategy`, `library_source` and `library_selection`, the terms used must conform to a **_controlled vocabulary_** specified by NCBI; see the "Library and Platform Terms" tab of the [SRA metadata submission template](https://ftp-trace.ncbi.nlm.nih.gov/sra/metadata_table/SRA_metadata_acc.xlsx) (`*.xlsx` file) for a list of current valid values.

#### Sample sheet columns for commonly used library-preparation protocols

For metagenomic sequencing, these three values should be:

| library_strategy | library_source | library_selection |
|------------------|----------------|-------------------|
| RNA-Seq          | VIRAL RNA      | cDNA              |


For amplicon sequencing, these values should be: 

| library_strategy | library_source | library_selection |
|------------------|----------------|-------------------|
| AMPLICON         | VIRAL RNA      | PCR               |


### Additional sample sheet columns helpful for internal QC checks

| amplicon_set | control | spike_in | viral_ct | batch_lib |
|--------------|---------|----------|----------|-----------|
|              |         |          |          |           |

 - `amplicon_set`: the name and version of amplicon primers or primer set used (ex. `ARTICv3`)
 - `control`: only one valid value: `NTC` (otherwise left blank)
 - `spike_in`: the identifier of the synthetic control added to an individual sample, if one was added (ex. `ERCC-00048`, `SDSI_19`)
 - `viral_ct`: the cycle threshold value of a qPCR assay performed on a sample prior to sequencing, as a proxy for the concentration of viral nucleic acid material present (ex. `16.2`); helpful for relating the quality of a sample to various sequencing metrics
 - `batch_lib`: an identifier for a batch of samples for which libraries were prepared in parallel

**A template sheet is available [here]()**

In the **Data** tab, click **Files** on the left-hand pane. If a folder called `samplesheets/` does not exist, click **New folder** and create a folder called `samplesheets`[^2]. Upload the sample sheet TSV provided, `flowcell_data.tsv`. Once uploaded, _right_ click on the uploaded file in Terra, and click **Copy Link Address** to copy the full path to the clipboard.

Click the `flowcell` table in the left-hand pane. Find the column called `samplesheets`, hover over the cell, and click the pencil icon to edit the samplesheet value(s) for the row present. In each of the four list entries, paste and replace the placeholder values with the full path copied in the previous step.

[^1]: A software-focused text editor is recommended for editing sample sheets, such as [Visual Studio Code](https://code.visualstudio.com/) or [Sublime Text](https://www.sublimetext.com/). The [bio-utils](https://marketplace.visualstudio.com/items?itemName=teselagen.vscode-bio-utils) (VSCode) or ["ACTG"](https://packagecontrol.io/packages/ACTG) (Sublime Text) add-ons may be helpful for viewing and manipulating index sequences. The [rainbow_csv](https://packagecontrol.io/packages/rainbow_csv) package (Sublime Text) enhances display of TSV files.
[^2]: The `samplesheets/` folder is used here to ease organization. The sample sheet files can be stored elsewhere as long as their full file paths are listed correctly in the table row(s) used as input for demultiplexing.

## Import the _demux\_deplete_ workflow

The workflow used here for demultiplexing pooled sequence libraries, `demux\_deplete` is listed on [Dockstore](https://dockstore.org/), a registry of published bioinformatics workflows.

Navigate to [https://dockstore.org](https://dockstore.org/), and either search for the workflow by name or navigate to it by clicking **Organizations**, then `Broad Institute of MIT and Harvard`, and finally `Viral Genomics`. 
In the list of workflows shown, scroll, locate, and click on the workflow named [broadinstitute/viral-pipelines/demux_deplete](https://dockstore.org/workflows/github.com/broadinstitute/viral-pipelines/demux_deplete:master?tab=info).

On the page for _demux\_deplete_, buttons are present on the right side of the page below **Launch with** to import the workflow for execution on one of several bioinformatics platforms.

Click the **Terra** button. A page from Terra will be displayed to import the workflow. In the drop-down menu, select the destination workspace, and click **Import**.
This will add _demux\_deplete_ to the group of pipelines listed under the **Workflows** tab of the workspace.
When first imported, Terra will immediately direct to the configuration settings for the workflow.

## Configure and execute the _demux\_deplete_ workflow

Access the _demux\_deplete_ workflow by clicking on the **Workflows** tab, and then the _demux\_deplete_ workflow.

Leave the `Version` drop-down menu to its default value, and click the radio button, **Run workflow(s) with inputs defined by data table**.

In the drop-down menu to the right of **Select root entity type:**, select `flowcell`, and click the **Select Data** button. Select the only row currently present in the `flowcell` table. Click **OK**.

Note that in the _demux\_deplete_ workflow, the `samplesheets` input field accepts a list of files.
The list of sample sheet files provided should include one sample sheet per flowcell lane. 
If the lanes contain differing pools of sequencing libraries, the sample sheet files should be listed in the same order as the lanes.
If the lanes contain the same pools, a single sample sheet should be listed multiple times, once per lane to demultiplex.

Demultiplexing jobs are executed in parallel for all lanes of a flowcell for which sample sheets are present, and the resulting sequence reads are merged on a per-library bases.

Configure the following workflow inputs to use data from the rows selected from the `flowcell` table:
 - `demux_deplete.flowcell_tgz` = `this.flowcell_tgz`
 - `demux_deplete.flowcell_tgz` = `this.samplesheets`

Configure the following workflow inputs to reference the databases referenced in the workflow data table; these will be used to remove human reads from the data and to count the number of reads present that align to the spike-in sequences listed in the `workspace.spikein_db` file.
 - `demux_deplete.blastDbs` = `workspace.blastDbs`
 - `demux_deplete.bwaDbs` = `workspace.bwaDbs`
 - `demux_deplete.spikein_db` = `workspace.spikein_db`

Click the **Save** button above the workflow input text boxes.

If input data have been selected and all of the required workflow inputs are specified, the **Run** button should be blue. Click the button to begin demultiplexing and depletion. A modal dialog will appear providing an opportunity to enter a comment about the compute job. Enter a comment if desired, and click **Launch**.

**_WAIT FOR DEMULTIPLEXING TO COMPLETE_**

## Use an interactive notebooks to create a table of samples after demultiplexing

Following demultiplexing, an interactive Jupyer notebook will be used to create or add rows to a table with per-sample data.

### Run the notebook

To create or use a notebook, a virtual compute instance containing Jupyter must be created or re-used.
These instances can be created or accessed via the **Analyses** tab of a Terra workspace.

On the **Analyses** tab, click `create_data_table_tsv.ipynb`

To create a new Jupyter notebook, click **+ START**, and click the **jupyter** button.

Navigate to the `flowcell` table, and copy the value of the `flowcell_id` for the row of the run being demultiplexed.

Navigate back to the Jupyer notebook and paste the `flowcell_id` in the text string, `flowcell_data_id`. 

From the **Cell** menu of the embedded Jupyer environment, click **Run All**. After a moment, the notebook will create a new table called `sample` and add a row for each demultiplexed library.

## Inspect the output of demultiplexing

If the input to demultiplexing is drawn from a row or rows in the `flowcell` table, outputs from demultiplexing will be added to the source row(s). This includes numeric metrics, file paths to files containing per-sample sequencing reads, and various metadata.

### Demultiplexing metrics

The file listed in the `demux_metrics` column for a demultiplexed flowcell contains metrics from [picard's `IlluminaBasecallsToSam`](https://broadinstitute.github.io/picard/command-line-overview.html#IlluminaBasecallsToSam), including the number of reads per sample name. The metrics file also lists the sequencing indices associated with each sample in the sample sheet. A zero or near-zero read count for a given sample may indicate that the indices for the sample were incorrect in the sample sheet, and may need to be corrected prior to demultiplexing again. The field `demux_outlierBarcodes` lists a file with abundant indices which were not included in the sample sheet; it can be helpful to check this file for potential sample sheet corrections.

### MultiQC reports

The `multiqc_report_raw` and `multiqc_report_cleaned` columns list combined reports containing quality metrics from FastQC (and potentially other tools), for raw reads and human-depleted reads, respectively. These show base quality scores by position in the reads, quality as a function of flowcell location, and other metrics of read quality.

### Spike-in read counts for evaluating cross-talk or contamination between samples

The `spikein_counts` column lists a file with a table listing counts of reads in each sample mapping to the known sequences of ERCC and SDSI synthetic controls. These controls are typically added ("spiked-in") each sample in a pool early in the library preparation process, with a distinct spike-in for each sample. In the ideal case, the `spikein_counts` report should list a moderate read account for only one spike-in for each sample. Should a sample have reads mapping to multiple synthetic controls, that could be an indication of cross-talk or contamination between samples, or "[index hopping](https://www.illumina.com/techniques/sequencing/ngs-library-prep/multiplexing/index-hopping.html)". 

### Data files

The (unmapped) sequence reads from _demux\_deplete_ used for subsequent analysis are contained in per-sample [`*.bam`](https://samtools.github.io/hts-specs/SAMv1.pdf) files:

 - `raw_reads_unaligned_bams`: each file contains all reads for a sample that passed filtering based on overall base quality
 - `cleaned_reads_unaligned_bams`: reads from `raw_reads_unaligned_bams` following removal (depletion) of reads mapping to the human genome, sequencing adapters, or common laboratory contaminants.
