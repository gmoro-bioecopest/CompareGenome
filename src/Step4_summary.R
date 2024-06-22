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


system(paste0("cd ", analysisdir, "PairwiseBlast; find $PWD -type f -name 'Output.txt' >", Inputdir, "PairwiseList.txt"))
BlastOutList <- read.table(paste0(Inputdir, "PairwiseList.txt"))

featlist <- read.csv(paste0(analysisdir, "SeqLength.csv"))
featlist$X <- NULL

featlist2 <- data.frame(query_id = featlist$basename, length = featlist$length)

for (blo in BlastOutList$V1) {
  as <- read.table(blo)
  colnames(as) <- c("subject_id", "query_id", "%_identity", "alignment_length", "mismatches", "gap_opens", "query_start", "query_end", "subject_start", "subject_end", "evalue", "bit_score", "subject_length", "query_seq", "subject_seq")

  as$query_length <- abs(as$query_start - as$query_end) + 1
  as$query_length <- as.numeric(as.character(as$query_length))


  as$`%_ofQueryCovered` <- round((as$alignment_length / as$query_length) * 100, 2)
  blo2 <- gsub("Output.txt", "Output.csv", blo)
  write.csv(as, blo2)

  as <- read.csv(blo2, check.names = F)
  if (nrow(as) == 0) { as <- read.csv(blo2, check.names = F) }

  as$corrected_perc_ofQueryCovered <- 100 - (abs(as$`%_ofQueryCovered` - 100))
  as$mypscore <- as$`%_identity` * (as$corrected_perc_ofQueryCovered / 100)


  as <- as[order(as$mypscore, decreasing = T),]
  as$uniqueID <- paste0(as$subject_id, "_Vs_", as$query_id)

  asr <- by(as, as["uniqueID"], head, n = 1)
  asr2 <- Reduce(rbind, asr)

  asr2 <- asr2[order(asr2$query_id, decreasing = T),]

  asr2$self <- ifelse(asr2$subject_id == asr2$query_id, "r", "l")
  asr2 <- subset(asr2, self == "l")

  faname2 <- gsub("Output.csv", "TopBitScore.csv", blo2)
  write.csv(asr2, faname2)
}


