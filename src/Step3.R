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


system(paste0("cd ", Outputdir, "; find $PWD -type f -name '*_blast.txt.gz' >", Inputdir, "BlastOutList.txt"))
BlastOutList <- read.table(paste0(Inputdir, "BlastOutList.txt"))

for (ckfs in BlastOutList$V1) {
  ckW1 <- gsub("_blast.txt.gz", "", ckfs)
  ckW2 <- gsub(".*RefSeq_Vs_", "", ckW1)

  ckfs2 <- gsub(".gz", "", ckfs)
  ckf <- subset(BlastOutList, V1 == ckfs)
  system(paste0("gunzip -k ", ckf$V1, ";cat ", ckfs2, " | grep -v '#' >", TempDir, "tempsplit.txt "))
  xsizefile <- paste0(TempDir, "tempsplit.txt")
  xsize <- file.size(xsizefile) == 0
  system(paste0("rm ", TempDir, "tempsplit.txt "))
  if (xsize == "TRUE") {
    BlastOutList <- subset(BlastOutList, !V1 == ckfs)
    system(paste0(" echo '\n\nWARNING: no alignment for \n", ckW2, ".\nThe file has been removed.' >>", JobDir, "Warnings.txt"))
  }
}

system(paste0("cd ", Outputdir, "; rm ./*/*.txt"))

newlist <- paste(BlastOutList$V1, collapse = "\n")
system(paste0(" cd ", Inputdir, "; cp BlastOutList.txt OldBlastOutList.txt"))
system(paste0(" echo '", newlist, "' >", Inputdir, "BlastOutList.txt"))

if (nrow(BlastOutList) > 1) {

  system(paste0("cd ", JobDir, "features; find $PWD -type f -name 'basename.txt' >", Inputdir, "FeatureList.txt"))
  featlist <- read.table(paste0(Inputdir, "FeatureList.txt"))



  featlist$basename <- gsub("/basename.txt", "", featlist$V1)
  featlist$basename <- gsub(".*/", "", featlist$basename)
  featlist$list <- 1:nrow(featlist)
  featlist$length <- ""

  for (featdb in featlist$V1) {
    featl <- subset(featlist, V1 == featdb)
    featdb2 <- gsub("basename.txt", "GENE_geneseq.txt", featdb)
    feats <- read.table(featdb2)
    if (nrow(feats) > 1) { feats2 <- data.frame(V1 = paste(feats$V1, collapse = "")); feats <- feats2 }

    nchar(feats$V1)
    featlist[featl$list, "length"] <- nchar(feats$V1)

  }
  write.csv(featlist, paste0(analysisdir, "SeqLength.csv"))

  featlist2 <- data.frame(query_id = featlist$basename, length = featlist$length)

  for (blo in BlastOutList$V1) {
    blofile <- gsub(".*/", "", blo)
    blofile
    blofold <- gsub(blofile, "", blo)

    system(paste0("cd ", blofold, "; gunzip -k ", blofile))
    blofileUn <- gsub("txt.gz", "txt", blofile)
    system(paste0("cd ", blofold, "; mkdir Split; split -l 1000000 ", blofileUn, ";mv x* Split/"))
    system(paste0("cd ", blofold, "; rm ", blofileUn))

    system(paste0("cd ", blofold, "Split; ls > splitlist.csv"))
    splitlist <- read.csv(paste0(blofold, "Split/splitlist.csv"), header = F)
    splitlist <- subset(splitlist, !V1 == "splitlist.csv")

    for (splitfile in splitlist$V1) {
      testblo <- paste0(blofold, "Split/", splitfile)

      as <- read.table(testblo)
      colnames(as) <- c("subject_id", "query_id", "%_identity", "alignment_length", "mismatches", "gap_opens", "query_start", "query_end", "subject_start", "subject_end", "evalue", "bit_score", "subject_length", "query_seq", "subject_seq")

      as <- merge(as, featlist2, by = "query_id", all = F)


      as$query_length <- as.numeric(as.character(as$length))
      as$length <- NULL

      as$`%_ofQueryCovered` <- round((as$alignment_length / as$query_length) * 100, 2)
      blo2 <- gsub("_blast.txt.gz", paste0("_", splitfile, "_blast.csv"), blo)



      as$corrected_perc_ofQueryCovered <- 100 - (abs(as$`%_ofQueryCovered` - 100))
      as$mypscore <- as$`%_identity` * (as$corrected_perc_ofQueryCovered / 100)

      as <- as[order(as$mypscore, decreasing = T),]
      asr <- by(as, as["query_id"], head, n = 1)
      asr2 <- Reduce(rbind, asr)

      asr2 <- asr2[order(asr2$query_id, decreasing = T),]

      asr2$seq <- paste0(">", asr2$query_id, "\n", asr2$subject_seq)
      faname <- gsub("_blast.csv", paste0("_TopBitScore.fa"), blo2)


      asr2$seq <- NULL

      faname2 <- gsub("_blast.csv", "_TopBitScore.csv", blo2)
      write.csv(asr2, faname2)
      system(paste0("cd ", blofold, "Split ; rm ", splitfile))

    }
    blo3 <- gsub("txt.gz", "csv", blofile)
    system(paste0("cd ", blofold, "; cat *TopBitScore.csv >", blo3))
    system(paste0("cd ", blofold, "; rm *TopBitScore.csv"))
    system(paste0("cd ", blofold, "; rm -rf Split"))
  }


  for (blo in BlastOutList$V1) {
    blo2 <- gsub("_blast.txt.gz", "_blast.csv", blo)


    as <- read.csv(blo2, check.names = F)
    if (nrow(as) == 0) { as <- read.csv(blo2, check.names = F) }
    as <- subset(as, !query_id == "query_id")

    as <- as[order(as$mypscore, decreasing = T),]
    asr <- by(as, as["query_id"], head, n = 1)
    asr2 <- Reduce(rbind, asr)

    asr2 <- asr2[order(asr2$query_id, decreasing = T),]

    asr2$seq <- paste0(">", asr2$query_id, "\n", asr2$subject_seq)
    faname <- gsub("_blast.csv", "_TopBitScore.fa", blo2)

    myseq <- paste(asr2$seq, collapse = "\n")
    write.table(myseq, faname, col.names = F, row.names = F)

    asr2$seq <- NULL

    faname2 <- gsub("_blast.csv", "_TopBitScore.csv", blo2)
    write.csv(asr2, faname2)
    system(paste0("rm ", blo, ";rm ", blo2))

  }


  system(paste0("cd ", Inputdir, ";sed 's/.txt.gz/.txt/' BlastOutList.txt >temp.txt; cp temp.txt BlastOutList.txt; rm temp.txt"))

}
if (nrow(BlastOutList) < 2) { system(paste0("echo '\n\nFATAL ERROR: some of the genome assemblies provided resulted in no alignment. Remove files and start again (see warning message for files to remove)' >>", JobDir, "FatalError.txt")) }

