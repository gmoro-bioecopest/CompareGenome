args <- commandArgs(trailingOnly = TRUE)


ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

mypattern <- "Pca"
analysisdir <- paste0(MyDir, mypattern, "/")

Inputdir <- paste0(analysisdir, "InputFiles/")
Outputdir <- paste0(analysisdir, "OutputFiles/")
Dbdir <- paste0(analysisdir, "/Subject_databases/")

system(paste0("mkdir -p ", analysisdir))


fulltable <- read.csv(paste0(MyDir, "Blast/Heatmaps/FullTableDf.csv"))

BlastOutList <- read.table(paste0(MyDir, "Blast/InputFiles/BlastOutList.txt"))
BlastOutList$label <- gsub(".*/", "", BlastOutList$V1)
BlastOutList$label <- gsub("RefSeq_Vs_", "", BlastOutList$label)
BlastOutList$label <- gsub("_blast.txt", "", BlastOutList$label)
BlastOutList$label

MyDfTable <- data.frame(Data = "Data", dplyr::select(fulltable, query_id, all_of(BlastOutList$label)))

for (i in names(MyDfTable[3:ncol(MyDfTable)])) {
  MyDfTable[[i]] <- round(MyDfTable[[i]], 0) + 1
}

row1 <- data.frame(MyDfTable[1,])
row1[1,] <- c("Data", "Factor", paste0("Observation", 1:(ncol(row1) - 2)))
row2 <- colnames(MyDfTable)
row1 <- rbind(row1, row2, MyDfTable)

names(row1) <- c("Info", paste0("col", 2:ncol(row1)))

write.csv(row1, paste0(analysisdir, "PcaDf.csv"), row.names = F)


CurrentRCode <- "Step7PCA.R"
AnalysisName <- "PCA"
Df_template <- "PcaDf.csv"

OutputFolder <- analysisdir

OutDir <- paste0(analysisdir, "Step7PCA.R") #get the path


expectedNames <- c("Factor", paste0("Observation", 1:100000))

AnalysisNo <- "PCAcompgen"

Dforig <- read.csv(paste0(analysisdir, "PcaDf.csv"))
Dforig2 <- subset(Dforig, !Info == "Info")
names(Dforig2) <- Dforig2[1,]
Dforig2 <- Dforig2[-1,]


Input <- data.frame(Data = rep("Data", each = nrow(Dforig2)))
for (i in expectedNames) {
  if (i %in% names(Dforig2)) { Input <- cbind(Input, Dforig2[i]) }
}

toclean <- Input[1,]
source(paste0(ScriptsDir, "CleanHeaders.R"))
Input[1,] <- toclean

NameMatch <- data.frame(Ref_labels = names(Input))
NameMatch$Custom_labels <- t(Input[1,])
Input <- Input[-1,]

OutF <- paste0(AnalysisNo, AnalysisName)
MainOutput <- paste0(gsub(CurrentRCode, "", OutDir), OutF, "/")
system(paste0("mkdir -p ", MainOutput))

write.csv(Input, paste0(MainOutput, "InputDf.csv"), row.names = F)
write.csv(NameMatch, paste0(MainOutput, "NameMatch.csv"), row.names = F)
write.csv(cldf, paste0(MainOutput, "Ylabels.csv"))

Input <- paste0(MainOutput, "InputDf.csv")

source(paste0(ScriptsDir, "PreliminaryFreeInfo.R"))

source(paste0(ScriptsDir, "DefaultInfo.R"))

names(loopf)
loopf$Treatment <- loopf$Factor

mainFact <- "Factor"
newrow <- data.frame(X = "", Info = "mainFact", Detail = mainFact, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)


names(loopf)
ObsList <- c("Observation")
newrow <- data.frame(X = "", Info = "ObsList", Detail = ObsList, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

names(loopf)
SpList <- c("Data") # use # for skipping.


system(paste0("mkdir -p ", MainOutput, "SplitDatasets"))

system(paste0("ls ", MainOutput))


print(paste0(Sys.time(), " : starting ", CurrentRCode))
source(paste0(ScriptsDir, "SplitDf2.R"))

system(paste0("cd ", MainOutput, "SplitDatasets", "; mkdir -p temp;cp *_Info.csv temp;cd temp;ls> list.csv"))
Infol <- read.csv(paste0(MainOutput, "SplitDatasets/temp/list.csv"), header = F)
Infol <- subset(Infol, !V1 == "list.csv")

for (myinfo in Infol$V1) {
  FFInfo <- read.csv(paste0(MainOutput, "SplitDatasets/temp/", myinfo))

  source(paste0(ScriptsDir, "FFInfoCode.R"))

  source(paste0(ScriptsDir, "PreliminaryFreeSetup.R"))


  FF <- read.csv(Input)
  editfol <- MyDir <- Anfold
  source(paste0(ScriptsDir, "Edit_PCA_Code.R"))


  FF <- read.csv(Input)
  Anfold <- Anfold #pca folder
  Setup_df <- paste0(Anfold, "PCA_SETUP.xlsx")
  Infofile <- paste0(Anfold, "Infofile.csv")

  source(paste0(ScriptsDir, "PlotPcaCoreCode2.R"))

  FFInfo$X <- NULL
  write.csv(FFInfo, paste0(Anfold, "Infofile.csv"))

}








