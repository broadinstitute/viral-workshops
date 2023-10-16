# Sequencing run demultiplexing

This is a walkthrough demonstrating demultiplexing of data from a viral sequencing run of pooled sequencing libraries.

# Contents
{:.no_toc}

1. Table of Contents
{:toc}

## Inspect and upload the sample sheet for the run to be demultiplexed

View the sample sheet file provided, called `SampleSheet_reprep_06_ss2.tsv`[^1].

In the **Data** tab, click **Files** on the left-hand pane. If a folder called `samplesheets/` does not exist, click **New folder** and create a folder called `samplesheets`[^2]. Upload the sample sheet TSV provided, `flowcell_data.tsv`. Once uploaded, _right_ click on the uploaded file in Terra, and click **Copy Link Address** to copy the full path to the clipboard.

Click the `flowcell` table in the left-hand pane. Find the column called `samplesheets`, hover over the cell, and click the pencil icon to edit the samplesheet value(s) for the row present. In each of the four list entries, paste and replace the placeholder values with the full path copied in the previous step.

[^1] A software-focused text editor is recommended for editing sample sheets, such as [Visual Studio Code](https://code.visualstudio.com/) or [Sublime Text](https://www.sublimetext.com/). The [bio-utils](https://marketplace.visualstudio.com/items?itemName=teselagen.vscode-bio-utils) (VSCode) or ["ACTG"](https://packagecontrol.io/packages/ACTG) (Sublime Text) add-ons may be helpful for viewing and manipulating index sequences. The [rainbow_csv](https://packagecontrol.io/packages/rainbow_csv) package (Sublime Text) enhances display of TSV files.
[^2] The `samplesheets/` folder is used here to ease organization. The sample sheet files can be stored elsewhere as long as their full file paths are listed correctly in the table row(s) used as input for demultiplexing.

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
