args <- commandArgs(trailingOnly = TRUE)


library(ggplot2)

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
plotdir <- paste0(analysisdir, "ViolinPlot/")
system(paste0("mkdir -p ", plotdir))


CurrentRCode <- "BoxPlotFreeCode.R"
print(paste0(Sys.time(), " : starting ", CurrentRCode))




BlastOutList <- read.table(paste0(Inputdir, "BlastOutList.txt"))
BlastOutList$V2 <- gsub("_blast.txt", "_TopBitScore.csv", BlastOutList$V1)

for (i in BlastOutList$V2) {
  system(paste0("cat ", i, " >>", analysisdir, "All_TopBitScore.csv"))
}
All_TopBitScore <- read.csv(paste0(analysisdir, "All_TopBitScore.csv"), check.names = F)
All_TopBitScore <- subset(All_TopBitScore, !query_id == "query_id")
All_TopBitScore$`%_identity` <- as.numeric(as.character(All_TopBitScore$`%_identity`))
All_TopBitScore$`%_ofQueryCovered` <- as.numeric(as.character(All_TopBitScore$`%_ofQueryCovered`))
All_TopBitScore$FinalScore <- as.numeric(as.character(All_TopBitScore$mypscore))

namessel <- c("query_id", "subject_id", "%_identity", "alignment_length", "mismatches", "gap_opens", "query_start", "query_end", "subject_start", "subject_end", "evalue", "bit_score", "subject_length", "query_seq", "subject_seq", "query_length", "%_ofQueryCovered", "corrected_perc_ofQueryCovered", "mypscore", "FinalScore")
All_T <- dplyr::select(All_TopBitScore, all_of(namessel))
allseq <- read.csv(paste0(analysisdir, "SeqLength.csv"))
missdf <- All_T[1,]
missdf$query_id <- "rm"

for (qid in unique(All_T$subject_id)) {
  All_Ts <- subset(All_T, subject_id == qid)

  for (qid2 in allseq$basename) {
    if (!qid2 %in% All_Ts$query_id) {
      newdf <- All_T[1,]
      newdf$query_id <- qid2
      newdf$subject_id <- qid
      newdf$alignment_length <- 0
      newdf$mismatches <- 0
      newdf$gap_opens <- 0
      newdf$query_start <- 0
      newdf$query_end <- 0
      newdf$subject_start <- 0
      newdf$subject_end <- 0
      newdf$evalue <- 0
      newdf$bit_score <- 0
      newdf$subject_length <- 0
      newdf$query_seq <- "NOTAPPLICABLE"
      newdf$subject_seq <- "NOTAPPLICABLE"
      newdf$query_length <- 0
      newdf$corrected_perc_ofQueryCovered <- 0
      newdf$mypscore <- 0
      newdf$FinalScore <- 0
      newdf$`%_identity` <- 0
      newdf$`%_ofQueryCovered` <- 0
      missdf <- rbind(missdf, newdf)
    }

  }
}

All_T <- rbind(All_T, missdf)
All_T <- subset(All_T, !query_id == "rm")
All_T3 <- All_T

All_T <- data.frame(X = "", All_T, check.names = F)
write.csv(All_T, paste0(analysisdir, "All_TopBitScoreBox.csv"))

Input <- paste0(analysisdir, "All_TopBitScoreBox.csv")
MainOutput <- plotdir

source(paste0(ScriptsDir, "/BoxPlots/Step3ViolinPlot/PreliminaryFreeInfo.R"))

source(paste0(ScriptsDir, "DefaultInfo.R"))

names(loopf)
loopf$Treatment <- paste0(loopf$subject_id)

names(loopf)
loopf$Replicate <- 1 #if missing and if there is only 1 replicate run the following loopf$Replicate=1

names(loopf)
loopf$PlotOrder <- 1 # if missing or if want alphabetical order use loopf$PlotOrder=1

names(loopf)
ObsList <- c("FinalScore")
newrow <- data.frame(X = "", Info = "ObsList", Detail = ObsList, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

names(loopf)
SpList <- c("Data") # use # for skipping.

system(paste0("mkdir -p ", MainOutput, "SplitDatasets"))

system(paste0("ls ", MainOutput))


source(paste0(ScriptsDir, "SplitDf.R"))

system(paste0("cd ", MainOutput, "SplitDatasets", "; mkdir -p temp;cp *_Info.csv temp;cd temp;ls> list.csv"))
Infol <- read.csv(paste0(MainOutput, "SplitDatasets/temp/list.csv"), header = F)
Infol <- subset(Infol, !V1 == "list.csv")

for (myinfo in Infol$V1) {
  FFInfo <- read.csv(paste0(MainOutput, "SplitDatasets/temp/", myinfo))

  source(paste0(ScriptsDir, "FFInfoCode.R"))


  source(paste0(ScriptsDir, "PreliminaryFreeSetup.R"))


  FF <- read.csv(Input, check.names = F)
  editfol <- Anfold
  source(paste0(ScriptsDir, "EditDfCode.R"))


  cfol <- Anfold
  EditDf_df <- paste0(Anfold, "EditDf_data.csv")
  source(paste0(ScriptsDir, "/BoxPlots/Step3ViolinPlot/BoxPlotCoreCode.R"))

}



