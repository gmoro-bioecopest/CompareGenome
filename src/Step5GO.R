args <- commandArgs(trailingOnly = TRUE)


library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(gplots)

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

plotdir <- paste0(analysisdir, "Heatmaps/")


All_TopBitScore <- read.csv(paste0(analysisdir, "All_TopBitScore.csv"), check.names = F)
All_TopBitScore <- subset(All_TopBitScore, !query_id == "query_id")
All_TopBitScore$`%_identity` <- as.numeric(as.character(All_TopBitScore$`%_identity`))
All_TopBitScore$`%_ofQueryCovered` <- as.numeric(as.character(All_TopBitScore$`%_ofQueryCovered`))
All_TopBitScore$FinalScore <- as.numeric(as.character(All_TopBitScore$mypscore))


rf <- All_TopBitScore
rf <- dplyr::select(rf, query_id, subject_id, FinalScore)

newscore <- read.csv(paste0(plotdir, "FullTableDf.csv"))
newscore$group <- ifelse(newscore$average >= 95, "MostSimilarSequences",
                         ifelse(newscore$average >= 85, "HighlySimilarSequences",
                               ifelse(newscore$average >= 70, "ModeratelySimilarSequences", "PoorlySimilarSequences"
                               )))

newscore$X <- NULL
write.csv(newscore, paste0(plotdir, "ScoreHeatmapDf_GO.csv"), row.names = F)

CurrentRCode <- "Step5GO.R"
print(paste0(Sys.time(), " : starting ", CurrentRCode))




Input <- paste0(plotdir, "ScoreHeatmapDf_GO.csv")
MainOutput <- plotdir

source(paste0(ScriptsDir, "PreliminaryFreeInfo.R"))

source(paste0(ScriptsDir, "DefaultInfo.R"))


names(loopf)
loopf$Treatment <- loopf$ProteinID

mainFact <- "ProteinID"
newrow <- data.frame(X = "", Info = "mainFact", Detail = mainFact, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

tempnewf <- read.csv(Input)
names(loopf)
ObsList <- unique(rf$subject_id)
newrow <- data.frame(X = "", Info = "ObsList", Detail = ObsList, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

loopf$group <- paste0(loopf$group, "_GO")

SpList <- c("group") # use # for skipping.

system(paste0("mkdir -p ", MainOutput, "SplitDatasetsGO"))



DoZscores <- "no" #options "yes" "no"

HeatCol <- "default" #options "default" and "custom" for apply (brewer.pal(9, "YlGnBu")) or colorRampPalette(c("yellow1","yellow2","yellow3", "black","blue3","blue2","blue1")), respectively


source(paste0(ScriptsDir, "SplitDf_Heatmaps.R"))


system(paste0("cd ", analysisdir, "Heatmaps; mv SplitDatasets/*GO_group* SplitDatasetsGO/"))

