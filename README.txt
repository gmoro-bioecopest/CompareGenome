Instructions (See examples at the end of the page)

PRELIMINARY SETTING
CompàreGenome requires Anaconda installed on your machine. If not already installed, please download and install the latest version of Anaconda.

Then, update and initiate your anaconda version by the following commands (based on version 22.9.0)
$ conda update -n base -c defaults conda    #to update. Please close and restart your shell after that
$ conda init     #to initiate. Please close and restart your shell after that


INSTALLATION

1-download the code and unzip

2-cd to the unzipped folder

3-run the following for installing

bash install.sh -n [number of cores in your processors] 
 


ARGUMENTS 

-n
It indicates the number of cores in your machine. 

-h or -help
It provides info about the usage of CompàreGenome. 

-g 
The full path of the genome assemblies to compare. The files must be in fasta format and at least 2 genome are required. If you have one genome assembly only, you can download the missing genome assembly from public databases. In this case it is best to choose the same species of your own assembly, or a closely related one.  

-r 
The full path of the reference genome, in genebank format. You can use your own reference file or alternatively download from public databases. It is best that the reference genome and your genome assemblies belong to the same species. In case this is not possible, you can choose the most closely related species. In case of  

-o  
The full path of the output folder. CompàreGenome will save analysis outputs in this folder.



EXAMPLES

Note1: before to start be sure that no conda environment is already activated


INSTALLATION

From the unzipped CompàreGenome folder (in the example CompareGenomeV2.1test), run install.sh by indicating the number of cores in your machine (in the example 8)

% cd /yourpath/CompareGenomeV2.1test
~CompareGenomeV2.1test %  bash install.sh -n 8 


ANALYSIS

Comparison of 2 genome assemblies (genome1.fa and genome2.fa)

~CompareGenomeV2.1test % bash comp-gen.sh -g /Users/gabriele/Rawdata/ShortSequences/genome1.fa /Users/gabriele/Rawdata/ShortSequences/genome2.fa -r /Users/gabriele/ReferenceFiles/MyReference.gbk -o /Users/gabriele/MyOutputFolder


Comparison of multiple genome assemblies, all saved in the same folder

~CompareGenomeV2.1test %  bash comp-gen.sh -g /Users/gabriele/Rawdata/ShortSequences/genome*.fa -r /Users/gabriele/ReferenceFiles/MyReference.gbk -o /Users/gabriele/MyOutputFolder

    