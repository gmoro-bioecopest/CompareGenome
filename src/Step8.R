args <- commandArgs(trailingOnly = TRUE)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")
outdir <- paste0(args[3], "/")

timefol <- paste0(outdir,"CompareGenome_",args[4], "/")

system(paste0(" mkdir -p ", timefol))

system(paste0("echo 'Glossary.

Query genomes: all the assembled genome sequences, in fasta format, provided by the user;

Reference genome: the reference genome, in genebank format, provided by the user;

Nucleotide sequence: every nucleotide sequence included in the reference genome file, including coding and non-coding sequences; 

Alignment score: calculated singularly for each nucleotide sequence in the reference genome, indicates the output of the blast-based alignment between the reference genome and each of the query genomes. The score is expressed as percentage and was calculated by considering the percentage of matching nucleotides (Identity) and the percentage of the reference sequence length aligned (Coverage);  

Pairwise alignment score: calculated singularly for each nucleotide sequence in the reference genome, indicates the mean alignment score, between each query genome and all the others. The score is expressed as percentage and was calculated by considering the percentage of matching nucleotides (Identity) and the percentage of the reference sequence length aligned (Coverage).


Figure and table captions.' >", timefol, "Outputs_description.txt"))

save_output_z <- function(myfile, newname, mycaption,Figfol) {
  
  system(paste0("cd ", Figfol, "; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
  system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfile, " not found' >> MissingOutputs.txt
else
 cp $(cat $FILE) ./", newname, "
 echo '", mycaption, "' >> Outputs_description.txt
fi"))
  
}

myfile <- "WholeGenomeComparison2.pdf"
newname <- "Fig1.pdf "
mycaption <- "\nFig1 - Comparison of the query genomes with the reference genome. Shown in A the alignment scores with all the nucleotide sequences of the reference genome, summarized as minimum, first quartile, median, third quartile and maximum (Outliers not shown). In B is shown the distribution of the scores within the 4 classes of similarity and the total number of aligned sequences/query genome."
Figfol=paste0(JobDir,"Outputs")
save_output_z(myfile, newname, mycaption,Figfol)

myfile <- "EditDf_data.csv"
newname <- "Fig1_data.csv"
mycaption <- ""
Figfol=paste0(JobDir,"Outputs/Blast/ViolinPlot")
#save_output_z(myfile, newname, mycaption,Figfol)

system(paste0("cd ", timefol, ";ls >list.csv"))
outl <- read.csv(paste0(timefol, "list.csv"), header = F)
if (newname %in% outl$V1) {
  tab1 <- read.csv(paste0(timefol, newname))
  
  scoresummary <- Rmisc::summarySE(data = tab1, measurevar = "ObservationValue",  #this is the column at y-axis
                                   groupvars = "Treatment") #this is the column at x-axis
  
  names(scoresummary) <- c("Genome ID", "Number Of Aligned Sequences", "Mean Alignment Score", " Standard Deviation", "Standard Error", "Confidence Interval")
  write.csv(scoresummary, paste0(timefol, newname))
}


myfile1 <- "FigPCA_AllData_RawDataDotPlot.pdf"
myfile2 <- "FigCluster_AllData_RawDataDendrogram.pdf"
mycaption <- "\nFig2A,Fig2B - Comparative analysis between the query genomes. Measurement of the relative genomic distance by the Principal Component Analysis (Fig2A) and by the Euclidean distance (Fig2B)."

system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile1, "' >", timefol, "outputlist.txt; find $PWD -type f -name '", myfile2, "' >>", timefol, "outputlist.txt"))

myfile <- myfile1
newname <- "Fig2A.pdf "
mycaption <- ""
Figfol=paste0(JobDir,"Outputs")
save_output_z(myfile, newname, mycaption,Figfol)

myfile <- myfile2
newname <- "Fig2B.pdf "
mycaption <- "Fig2A,Fig2B - Comparative analysis between the query genomes. Measurement of the relative genomic distance by the Principal Component Analysis (Fig2A) and by the Euclidean distance (Fig2B)."
Figfol=paste0(JobDir,"Outputs")
save_output_z(myfile, newname, mycaption,Figfol)


myfile <- "*GO_enrichment.pdf"
mycaption <- "\nFig3A,Fig3B,Fig3C,Fig3D - Functional analysis on the query genomes. GO enrichment analysis on the most conserved gene sequences (pairwise alignment score: 95 to 100%, Fig3A), on the highly similar gene sequences (pairwise alignment score: 85 to 95%, Fig3B), on the moderately similar gene sequences (pairwise alignment score: 70 to 85%, Fig3C) and on the most different gene sequences (pairwise alignment score <70%, Fig3D). Shown the top 20 enriched GO terms (P<0.05, Fisher s test), sorted by the count of gene sequences/GO term.
NOTE: some genes are not associated to any GO term. These genes have been automatically removed and not considered in the enrichment analysis."
extranote="NOTE: there may be a repetition of the same GO term in two or more Similarity Classes (potentially all of 4). That is not a mistake as the genes within each class will be different. That happens in particular when many gene are annotated with the same GO terms but the similarity score of these genes makes them assign to different similarity classes."

system(paste0("echo '", mycaption, "' >> ",timefol,"Outputs_description.txt; echo '", extranote, "' >> ",timefol,"Outputs_description.txt"))
system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))


myfile <- "MostSimilar*enrichment.pdf"
myfileRN <- "MostConservedSequences_GOenrichment.pdf"
newname <- "Fig3A.pdf "

system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfileRN, " not found' >> MissingOutputs.txt
 echo 'NOTE: missing ", newname, "' >> Outputs_description.txt
else
 cp $FILE ./", newname, "
fi"))

myfile <- "HighlySimilar*enrichment.pdf"
myfileRN <- "HighlyConservedSequences_GOenrichment.pdf"
newname <- "Fig3B.pdf "

system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfileRN, " not found' >> MissingOutputs.txt
 echo 'NOTE: missing ", newname, "' >> Outputs_description.txt
else
 cp $(cat $FILE) ./", newname, "
fi"))

myfile <- "ModeratelySimilar*enrichment.pdf"
myfileRN <- "ModeratelyConservedSequences_GOenrichment.pdf"
newname <- "Fig3C.pdf "

system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfileRN, " not found' >> MissingOutputs.txt
 echo 'NOTE: missing ", newname, "' >> Outputs_description.txt
else
 cp $(cat $FILE) ./", newname, "
fi"))


myfile <- "PoorlySimilar*enrichment.pdf"
myfileRN <- "MostVariableSequences_GOenrichment.pdf"
newname <- "Fig3D.pdf "

system(paste0("cd ", JobDir, "Outputs; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfileRN, " not found' >> MissingOutputs.txt
 echo 'NOTE: missing ", newname, "' >> Outputs_description.txt
else
 cp $(cat $FILE) ./", newname, "
fi"))


myfile <- "CorrelationMatrix.pdf"
newname <- "Fig4.pdf "
mycaption <- "\nFig4 - Correlation matrix plot for the query genomes (Person correlation coefficient applied), calculated on the pairwise alignment scores."
Figfol=paste0(JobDir,"Outputs")
save_output_z(myfile, newname, mycaption,Figfol)

myfile <- "CorrelationTable.csv"
newname <- "Fig4_data.csv"
mycaption <- ""
Figfol=paste0(JobDir,"Outputs")
save_output_z(myfile, newname, mycaption,Figfol)

myfile <- "ScoreHeatmapDf_GO.csv"
newname <- "Table1.csv"
mycaption <- "\nTable1 -  Summary table. For each sequence in the reference genome (Reference_sequence), reported information about the resulting gene and product (SequenceID, ProteinID, Product);the Pairwise Similarity Class; the SimilarityRank, indicating the order of sequences according to the pairwise alignment score (1=most conserved sequence); the pairwise alignment scores for each query genome; standard deviation, average of pairwise alignment scores and pairwise similarity class."

system(paste0("cd ", JobDir, "Outputs/; find $PWD -type f -name '", myfile, "' >", timefol, "outputlist.txt"))
system(paste0("cd ", timefol, ";FILE=outputlist.txt ;
if
 [ -z $(grep '[^[:space:]]' $FILE) ];
then
 echo '", myfile, " not found' >> MissingOutputs.txt
 echo '", myfile, " n' > tablelist.txt
else
 echo '", myfile, " y' > tablelist.txt
 echo '", mycaption, "' >> Outputs_description.txt
 cp $(cat $FILE) ./", newname, "
fi"))

ol <- read.table(paste0(timefol, "tablelist.txt"), header = F)

if (ol$V2 == "y") {
  at <- read.csv(paste0(timefol, newname))
  at$X <- NULL
  
  at$row <- 1:nrow(at)
  at$GeneID <- "Unknown"
  at$PairwiseSimilarityClass <- at$group
  unique(at$group)
  at$PairwiseSimilarityClass <- gsub("MostSimilarSequences", "MostConservedSequences", at$PairwiseSimilarityClass)
  at$PairwiseSimilarityClass <- gsub("HighlySimilarSequences", "HighlyConservedSequences", at$PairwiseSimilarityClass)
  at$PairwiseSimilarityClass <- gsub("ModeratelySimilarSequences", "ModeratelyConservedSequences", at$PairwiseSimilarityClass)
  at$PairwiseSimilarityClass <- gsub("PoorlySimilarSequences", "MostVariableSequences", at$PairwiseSimilarityClass)
  
  for (refid in at$query_id) {
    at2 <- subset(at, query_id == refid)
    geneid <- read.csv(paste0(JobDir, "features/", refid, "/GENE_geneID.txt"), header = F)
    at[at2$row, "GeneID"] <- geneid$V1
  }
  
  
  at2 <- data.frame(Reference_sequence = at$query_id, SequenceID = at$GeneID, ProteinID = at$protein_id, Product = at$ProductID, PairwiseSimilarityClass = at$PairwiseSimilarityClass)
  at$query_id <- NULL
  at$GeneID <- NULL
  at$protein_id <- NULL
  at$ProductID <- NULL
  at$group <- NULL
  at$rows <- NULL
  at$PairwiseSimilarityClass <- NULL
  
  at2$SimilarityRank <- at$SimilarityRank
  at$SimilarityRank <- NULL
  
  at2 <- cbind(at2, at)
  at2$row <- NULL
  
  write.csv(at2, paste0(timefol, newname))
  
}

mycaption="\n\nMissingOutputs: when present, it lists all the analyses expected to be done but actually missing. The most common file missing are ones related to GO enrichment analysis and the reason must be found in the uncomplete GO annotation in the reference genome provided. To avoid that, try to provide a fully annotated genome as reference."
system(paste0("echo '", mycaption, "' >> ",timefol,"Outputs_description.txt"))

system(paste0("cd ", timefol, ";rm outputlist.txt; rm tablelist.txt; rm list.csv"))
#system(paste0("cp ",JobDir,"R_out_job/job*.txt ",timefol))
