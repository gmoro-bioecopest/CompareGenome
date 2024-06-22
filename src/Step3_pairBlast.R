args <- commandArgs(trailingOnly = TRUE)

library(seqinr)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")


mypattern <- "Blast"
analysisdir <- paste0(MyDir, mypattern, "/")

Inputdir <- paste0(analysisdir, "InputFiles/")
Outputdir <- paste0(analysisdir, "OutputFiles/")
Dbdir <- paste0(analysisdir, "/Subject_databases/")


Seqdb <- read.csv(paste0(analysisdir, "All_TopBitScore.csv"), check.names = F)
Seqdb <- subset(Seqdb, !query_id == "query_id")
assemblyList <- unique(Seqdb$subject_id)
seqlist <- unique(Seqdb$query_id)
system(paste0("mkdir -p ", analysisdir, "PairwiseBlast"))

for (iseq in seqlist) {
  subf <- paste0(analysisdir, "PairwiseBlast/", iseq)
  subsb <- subset(Seqdb, query_id == iseq)
  system(paste0("mkdir -p ", subf))

  subsb$seq <- paste0(">", subsb$subject_id, "\n", subsb$subject_seq)

  myseq <- paste(subsb$seq, collapse = "\n")
  write.table(myseq, paste0(subf, "/Dbase.fa"), col.names = F, row.names = F)
  reffile <- paste0(JobDir, "features/", iseq, "/geneseq.fa")
  system(paste0("cd ", subf, "; cat Dbase.fa ", reffile, " >Dbase2.fa; mv Dbase2.fa Dbase.fa"))
  system(paste0("cp ", ScriptsDir, "RemoveQuotesPairwise.txt ", subf))
  system(paste0("cd ", subf, "; sh RemoveQuotesPairwise.txt "))
}



