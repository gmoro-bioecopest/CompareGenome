# CompareGenome

CompàreGenome: a command-line tool for comparative genome analysis

## PRELIMINARY SETTING
CompàreGenome requires Anaconda installed on your machine. 
If not already installed, please download and install 
the [latest version of Anaconda](https://www.anaconda.com/download/).

Then, update and initiate your anaconda version by the following commands (based on version 22.9.0)
```shell
$ conda update -n base -c defaults conda    #to update. Please close and restart your shell after that
$ conda init     #to initiate. Please close and restart your shell after that
```


## INSTALLATION

The installation may take several minutes.

1. Clone the repository:
    ```shell
    $ git clone https://github.com/gmoro-bioecopest/CompareGenome.git
    ```
Alternatively, download and unzip

2. Navigate into the CompareGenome directory:
    ```shell
    $ cd CompareGenome
    ```

3. Run the following command to install:
    ```shell
    $ bash install.sh -n [Number of cores to use. ]
    ```
**Note:** The default value for the number of cores is set to half of the total number of cores in the system.

After the installation process completes, the tool will be available in the current directory and can be executed with the command:
    `./bash comp-gene.sh`


## ARGUMENTS
- Show help:
    ```shell
    $ ./comp-gene -h
    ```

    ```shell
    Usage: comp-gene.sh      [--num-cores/-n <num_cores>] [--reference/-r <reference_file>]
                            [--genomes/-g <list of genomes to compare>]
                            [--output-dir/-o <output_folder>]

    Run CompareGenome with the specified options.

    Options:
      --num-cores, -n   Number of core to use. Default: 4

      --reference, -r   The full path of the reference genome, in genebank format.
                        You can use your own reference file or alternatively download from public databases.
                        It is best that the reference genome and your genome assemblies belong to the same species.
                        In case this is not possible, you can choose the most closely related species.

      --genomes,   -g   The full path of the genome assemblies to compare.
                        The files must be in fasta format and at least 2 genomes are required.
                        If you have one genome assembly only, you can download the missing genome assembly from public databases.
                        In this case it is best to choose the same species of your own assembly, or a closely related one.

      --output-dir,-o   The full path of the output folder. CompareGenome will save analysis outputs in this folder.

      --help, -h        Show this help message and exit
    ```
  
TUTORIAL WITH TEST DATA

Here the instructions for running CompàreGenome with the test data provided with the documentation.

Note1: before to start be sure that no conda environment is already activated


1-Installation

From the unzipped CompàreGenome folder (let's name it CompareGenomeV2.1test), run install.sh by indicating the number of cores in your machine (in the example 8)

```shell
    % cd /yourpath/CompareGenomeV2.1test
    ~CompareGenomeV2.1test %  bash install.sh -n 8 
```
2-Analysis (it may take a while)

From /yourpath/CompareGenomeV2.1test, unzip the compressed folder data/TestData.tar.bz2 to have access to the 3 genome assemblies in fasta format (Genome1.fa, Genome2.fa, Genome3.fa) and to the reference genome in genebank format (RefGenome.gbk). Then run the following:

```shell
~CompareGenomeV2.1test % bash comp-gene.sh -g /yourpath/CompareGenomeV2.1test/data/Test/Genome1.fa /yourpath/CompareGenomeV2.1test/data/Test/Genome2.fa /yourpath/CompareGenomeV2.1test/data/Test/Genome3.fa -r /yourpath/CompareGenomeV2.1test/data/Test/RefGenome.gbk -o /yourpath/CompareGenomeV2.1test/data/Test
```
or alternatively

```shell
~CompareGenomeV2.1test % bash comp-gene.sh -g /yourpath/CompareGenomeV2.1test/data/Test/Genome*.fa -r /yourpath/CompareGenomeV2.1test/data/Test/RefGenome.gbk -o /yourpath/CompareGenomeV2.1test/data/Test
```
3-Outputs

After CompàreGenome completes the analysis, there will be the following output files in selected output folder:

Fig1 - Comparison of the query genomes with the reference genome. Shown in A the alignment scores with all the nucleotide sequences of the reference genome, summarized as minimum, first quartile, median, third quartile and maximum (Outliers not shown). In B is shown the distribution of the scores within the 4 classes of similarity and the total number of aligned sequences/query genome.

Fig2A,Fig2B - Comparative analysis between the query genomes. Measurement of the relative genomic distance by the Principal Component Analysis (Fig2A) and by the Euclidean distance (Fig2B).

Fig3A,Fig3B,Fig3C,Fig3D - Functional analysis on the query genomes. GO enrichment analysis on the most conserved gene sequences (pairwise alignment score: 95 to 100%, Fig3A), on the highly similar gene sequences (pairwise alignment score: 85 to 95%, Fig3B), on the moderately similar gene sequences (pairwise alignment score: 70 to 85%, Fig3C) and on the most different gene sequences (pairwise alignment score <70%, Fig3D). Shown the top 20 enriched GO terms (P<0.05, Fisher s test), sorted by the count of gene sequences/GO term.

Fig4,Fig4_data.csv - Correlation matrix for the query genomes (Person correlation coefficient applied), calculated on the pairwise alignment scores.

Table1.csv - Summary table. For each sequence in the reference genome (Reference_sequence), reported information about the resulting gene and product (SequenceID, ProteinID, Product);the Pairwise Similarity Class; the SimilarityRank, indicating the order of sequences according to the pairwise alignment score (1=most conserved sequence); the pairwise alignment scores for each query genome; standard deviation, average of pairwise alignment scores and pairwise similarity class.

MissingOutputs.txt - Warning message file. It indicates eventually missing outputs.
Output_description.txt - It provides  a description of all the outputs.
