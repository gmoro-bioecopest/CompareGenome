args <- commandArgs(trailingOnly = TRUE)


library(dplyr)
library(ggplot2)
ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

mypattern <- "GO_Enrichment"
analysisdir <- paste0(MyDir, mypattern, "/")

system(paste0("mkdir -p ", analysisdir))

selectionDir <- paste0(JobDir, "features/")
system(paste0("echo 'rm' >", MyDir, "GoFullList.csv")) #create a default file
system(paste0("cd ", JobDir, "features; for i in ./*/UniqueGO_terms.txt; do cat $i >>", MyDir, "GoFullList.csv;done"))
go <- read.csv(paste0(MyDir, "GoFullList.csv"), header = F)
go <- subset(go, !V1 == "rm")

if (nrow(go) == 0) { system(paste0("echo 'no' >", MyDir, "DoGO.txt; echo 'GO enrichment analysis failed due to empty GO terms list' >>", JobDir, "ErrorList.txt")) }
if (nrow(go) > 0) { system(paste0("echo 'yes' >", MyDir, "DoGO.txt")) }

if (nrow(go) > 0) {
  goUnique <- data.frame(GOID = go[!duplicated(go[, c("V1")]),])
  goUnique$Frequency <- 0
  goUnique$list <- 1:nrow(goUnique)
  for (i in goUnique$GOID) {
    gosub <- subset(goUnique, GOID == i)
    go$V2 <- ifelse(go$V1 == i, 1, 0)
    sum(go$V2)
    goUnique[gosub$list, "Frequency"] <- sum(go$V2)
  }

  goids <- c(goUnique$GOID)  #### your GO ids

  if (requireNamespace("GO.db", quietly = TRUE)){

  library(GO.db)
  goterms <- data.frame(GOID(GOTERM),Ontology(GOTERM),Term(GOTERM),Definition(GOTERM))
  names(goterms)=c("GOID","ONTOLOGY","TERM","DEFINITION")
  goterms=subset(goterms,!GOID=="all")
  write.csv(goterms,paste0(ScriptsDir,"goterms_update.csv"))
  goterms <- read.csv(paste0(ScriptsDir, "goterms_update.csv"), row.names = 1)
  }else{goterms <- read.csv(paste0(ScriptsDir, "goterms_default.csv"), row.names = 1)}
  
  
  
  gotable <- goterms
  gotable$sel <- ifelse(gotable$GOID %in% goids, "y", "n")
  gotable <- subset(gotable, sel == "y")
  gotable$sel <- NULL

  goUnique2 <- merge(goUnique, gotable, by = "GOID", all = F)
  write.csv(goUnique2, paste0(MyDir, "GoFullAnnotation.csv"))

  system(paste0("cd ", MyDir, "Blast/Heatmaps/SplitDatasetsGO; find $PWD -type f -name '*_group_Df.csv' >", analysisdir, "Dflist.csv"))
  Dflist <- read.csv(paste0(analysisdir, "Dflist.csv"), header = F)
  fulltable <- read.csv(paste0(MyDir, "Blast/Heatmaps/FullTableDf.csv"))

  fulltable$ProteinID <- paste0(fulltable$protein_id, " ", fulltable$ProductID)
  for (score in Dflist$V1) {
    scoret <- read.csv(score)
    scoret$ProductID <- ifelse(nchar(scoret$ProductID) > 50, paste0(substr(scoret$ProductID, 1, 50), "..."), scoret$ProductID)
    scoret$ProteinID <- paste0(scoret$protein_id, " ", scoret$ProductID)
    scoret <- scoret[!duplicated(scoret[, c("ProteinID")]),]


    fulltable2 <- fulltable
    fulltable2$ProductID <- ifelse(nchar(fulltable2$ProductID) > 50, paste0(substr(fulltable2$ProductID, 1, 50), "..."), fulltable2$ProductID)
    fulltable2$ProteinID <- paste0(fulltable2$protein_id, " ", fulltable2$ProductID)

    fulltable2$m <- ifelse(fulltable2$ProteinID %in% scoret$ProteinID, "y", "n")
    fulltable2 <- subset(fulltable2, m == "y")
    fulltable2 <- fulltable2[!duplicated(fulltable2[, c("ProteinID")]),]
    fulltable2 <- fulltable2[order(fulltable2$ProteinID, decreasing = F),]
    scoret <- scoret[order(scoret$ProteinID, decreasing = F),]
    scoret$query_id <- fulltable2$query_id


    scoret$X <- NULL
    strainlist <- data.frame(list = names(fulltable))
    namestoremove <- c("X", "query_id", "rows", "protein_id", "ProductID", "st_dev", "group", "ProteinID")
    for (i in namestoremove) {
      strainlist <- subset(strainlist, !list == i)
    }

    scorefile <- scoret
    if (nrow(scorefile) > 0) {
      scorefname <- gsub(".*/", "", score)
      scorefold <- gsub(scorefname, "", score)

      scorefold <- gsub("Blast/Heatmaps/SplitDatasetsGO/", "GO_Enrichment/", scorefold)
      scorefname <- gsub("_group_Df.csv", "", scorefname)
      scorefold <- paste0(scorefold, "/", scorefname, "/")
      system(paste0("mkdir -p ", scorefold))

      for (ref in scorefile$query_id) { system(paste0("cat ", selectionDir, ref, "/UniqueGO_terms.txt >>", scorefold, "GroupGoList.csv")) }


      goscore <- read.csv(paste0(scorefold, "GroupGoList.csv"), header = F)

      goscoreUnique <- data.frame(GOID = goscore[!duplicated(goscore[, c("V1")]),])
      goscoreUnique$Frequency <- 0
      goscoreUnique$list <- 1:nrow(goscoreUnique)
      for (i in goscoreUnique$GOID) {
        goscoresub <- subset(goscoreUnique, GOID == i)
        goscore$V2 <- ifelse(goscore$V1 == i, 1, 0)
        goscoreUnique[goscoresub$list, "Frequency"] <- sum(goscore$V2)
      }

      goUnique2ref <- goUnique2
      goUnique2ref$Frequency <- NULL
      goUnique2ref$list <- NULL
      goscoreUnique2 <- merge(goscoreUnique, goUnique2ref, by = "GOID", all = F)

      ObtainedData <- goscoreUnique2 #load file with real data
      ObtainedData$List <- ObtainedData$TERM #column with list of elements
      ObtainedData$Obtained <- ObtainedData$Frequency #column with count of elements
      ObtainedData$Total <- sum(ObtainedData$Frequency) #total elements

      ReferenceData <- goUnique2 #load file with reference data
      ReferenceData$List <- ReferenceData$TERM #column with list of elements
      ReferenceData$ReferenceData <- ReferenceData$Frequency #column with count of elements
      ReferenceData$Total <- sum(ReferenceData$Frequency) #total elements

      Anfold <- scorefold
      FFInfo <- data.frame(X = "", Info = c("ScriptsDir",
                                            "TempDir",
                                            "Input",
                                            "Output"))
      FFInfo$Detail <- c(ScriptsDir, TempDir,
                         paste0(scorefold, "PositivelyEnrichedOnly.csv"),
                         scorefold)
      FFInfo$Description <- ""
      FFInfo$Requisites <- ""

      source(paste0(ScriptsDir, "EnrichmentFreeCode.R"))
    }

  }
}
