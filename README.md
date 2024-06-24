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
    `./comp-gene.sh`


## ARGUMENTS
- Show help:
    ```shell
    $ ./comp-gene.sh -h
    ```

    ```shell
    Usage: comp-gene.sh         [--num-cores/-n <num_cores>] [--reference/-r <reference_file>]
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
  
## EXAMPLES
#Note: before to start be sure that no conda environment is already activated

INSTALLATION

From the unzipped CompàreGenome folder (in the example CompareGenomeV2.1test), run install.sh by indicating the number of cores in your machine (in the example 8)
```shell
    % cd /yourpath/CompareGenomeV2.1test
    ~CompareGenomeV2.1test %  bash install.sh -n 8 
```
ANALYSIS

Comparison of 2 genome assemblies (genome1.fa and genome2.fa)
```shell
    ~CompareGenomeV2.1test % bash comp-gene.sh \ 
    -g /Users/gabriele/Rawdata/ShortSequences/genome1.fa /Users/gabriele/Rawdata/ShortSequences/genome2.fa \ 
    -r /Users/gabriele/ReferenceFiles/MyReference.gbk \ 
    -o /Users/gabriele/MyOutputFolder
```
Comparison of multiple genome assemblies, all in the same folder
```shell
    ~CompareGenomeV2.1test % bash comp-gene.sh \
    -g /Users/gabriele/Rawdata/ShortSequences/genome*.fa \
    -r /Users/gabriele/ReferenceFiles/MyReference.gbk \
    -o /Users/gabriele/MyOutputFolder
```
    