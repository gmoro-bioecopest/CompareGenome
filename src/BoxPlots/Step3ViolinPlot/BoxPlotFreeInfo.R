
ScriptsDir <- "~/Dropbox/desktop_generale/MainSetupFolder/Analyses/MyPipelines/Analysessrc/"
Input <- "~/Dropbox/desktop_generale/lavoro/Science_2/Projects/PprotegensBeesUniss/EXPERIMENTS_PprotegensBeesUniss/Pprotegens_Vs_Paeruginosa/DataAnalysis/Outputs/BlastOfAnnotated/BlastEvaluation/comp/TopBitScore/AllStrains.csv"
MainOutput <- "~/Dropbox/desktop_generale/lavoro/Science_2/Projects/PprotegensBeesUniss/EXPERIMENTS_PprotegensBeesUniss/Pprotegens_Vs_Paeruginosa/DataAnalysis/Outputs/BlastOfAnnotated/BlastEvaluation/comp/TopBitScore/"

source(paste0(ScriptsDir, "PreliminaryFreeInfo.R"))

source(paste0(ScriptsDir, "DefaultInfo.R"))

names(loopf)
loopf$Treatment <- paste0(loopf$subject_id, loopf$ID)

names(loopf)
loopf$Replicate <- 1 #if missing and if there is only 1 replicate run the following loopf$Replicate=1

names(loopf)
loopf$PlotOrder <- 1 # if missing or if want alphabetical order use loopf$PlotOrder=1

names(loopf)
ObsList <- c("Score")
newrow <- data.frame(X = "", Info = "ObsList", Detail = ObsList, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

names(loopf)
SpList <- c("GeneGroup") # use # for skipping.

system(paste0("mkdir -p ", MainOutput, "SplitDatasets"))

system(paste0("ls ", MainOutput))









