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

system(paste0("mkdir -p ", plotdir))

All_TopBitScore <- read.csv(paste0(analysisdir, "All_TopBitScore.csv"), check.names = F)
All_TopBitScore <- subset(All_TopBitScore, !query_id == "query_id")
All_TopBitScore$`%_identity` <- as.numeric(as.character(All_TopBitScore$`%_identity`))
All_TopBitScore$`%_ofQueryCovered` <- as.numeric(as.character(All_TopBitScore$`%_ofQueryCovered`))
All_TopBitScore$FinalScore <- as.numeric(as.character(All_TopBitScore$mypscore))


rf <- All_TopBitScore
rf <- dplyr::select(rf, query_id, subject_id, FinalScore)

queryls <- data.frame(query_id = unique(rf$query_id), present = 0)
queryls2 <- queryls
for (asb in unique(rf$subject_id)) {
  rfs <- subset(rf, subject_id == asb)
  rfs <- dplyr::select(rfs, query_id, FinalScore)
  queryls2$present <- ifelse(queryls2$query_id %in% rfs$query_id, 1, 0)
  missing <- subset(queryls2, present == 0)
  names(rfs) <- c("query_id", asb)
  names(missing) <- c("query_id", asb)
  final <- rbind(rfs, missing)
  queryls <- merge(queryls, final, by = "query_id", all = F)
}
queryls$present <- NULL

cnameslist <- names(queryls[2:ncol(queryls)])
queryls$row <- 1:nrow(queryls)


for (cseq in queryls$query_id) {
  pwscore <- read.csv(paste0(analysisdir, "PairwiseBlast/", cseq, "/TopBitScore.csv"), check.names = F)
  subq <- subset(queryls, query_id == cseq)
  subqrow <- subq$row
  for (cname in cnameslist) {

    cnameslist2 <- c(cnameslist, cseq); newlg <- c("rm")
    for (lg2 in cnameslist2) {
      if (!cname == lg2) {
        newlg2 <- paste0(cname, "_Vs_", lg2)
        newlg <- c(newlg, newlg2)
      }
    }
    newlg <- data.frame(Comb = newlg)
    newlg <- subset(newlg, !Comb == "rm")

    subpw <- pwscore
    subpw$match <- ifelse(grepl(cname, subpw$uniqueID), "y", "n")
    subpw <- subset(subpw, match == "y")
    if (nrow(subpw) == 0) { meanscore <- 0 }

    if (!nrow(subpw) == 0) {
      subpw$match1 <- ifelse(subpw$uniqueID %in% newlg$Comb, "y", "n")
      subpw$first <- gsub("_Vs_.*", "", subpw$uniqueID)
      subpw$second <- gsub(".*_Vs_", "", subpw$uniqueID)
      subpw$rev <- paste0(subpw$second, "_Vs_", subpw$first)
      subpw$match2 <- ifelse(subpw$rev %in% newlg$Comb, "y", "n")


      subpwF <- subset(subpw, match1 == "y")
      subpwS <- subset(subpw, match2 == "y")
      subpwS$uniqueID <- subpwS$rev
      subpwC <- rbind(subpwF, subpwS)
      subpwC <- subpwC[!duplicated(subpwC[, c("uniqueID")]),]
      missingrows <- nrow(newlg) - nrow(subpwC)
      if (missingrows == 0) { meanscore <- mean(subpwC$mypscore) }
      if (missingrows > 0) {
        newlist <- c(subpwC$mypscore, rep(0, each = missingrows))
        meanscore <- mean(newlist)
      }

    }

    queryls[subqrow, cname] <- meanscore
  }

}
queryls$row <- NULL


annf <- data.frame(query_id = queryls$query_id, protein_id = "", ProductID = "")
annf$rows <- 1:nrow(annf)
for (geid in queryls$query_id) {
  anns <- subset(annf, query_id == geid)

  pid <- read.csv(paste0(JobDir, "features/", geid, "/CDS_protein_id.txt"), header = F)
  annf[anns$rows, "protein_id"] <- pid$V1

  mynote <- "Unclassified" #default
  note1 <- read.csv(paste0(JobDir, "features/", geid, "/note1.txt"), header = F)
  note2 <- read.csv(paste0(JobDir, "features/", geid, "/note2.txt"), header = F)
  note3 <- read.csv(paste0(JobDir, "features/", geid, "/note3.txt"), header = F)

  if (!note1$V1 == "Unclassified") { mynote <- note1$V1 }else {
    if (!note2$V1 == "Unclassified") { mynote <- note2$V1 }else {
      if (!note3$V1 == "Unclassified") { mynote <- note3$V1 }
    }
  }

  annf[anns$rows, "ProductID"] <- mynote
}

reserve <- annf

annf$rows <- NULL
queryls$st_dev <- 1
queryls$average <- 1
queryls$rows <- 1:nrow(queryls)
nc <- (ncol(queryls) - 3)

for (geid in queryls$query_id) {
  quer <- subset(queryls, query_id == geid)

  quern <- quer[2:nc]
  quern <- as.numeric(as.character(quern[1,]))
  mysd <- sd(quern)
  mymean <- mean(quern)

  queryls[quer$rows, "st_dev"] <- mysd
  queryls[quer$rows, "average"] <- mymean
}


queryls <- queryls[order(-queryls$average, queryls$st_dev),]
queryls$SimilarityRank <- 1:nrow(queryls)

queryls <- merge(queryls, annf, by = "query_id", all = F)
queryls$ProductID <- gsub("[[:punct:]]", "_", queryls$ProductID)


queryls <- queryls[order(queryls$SimilarityRank, decreasing = F),]
if (nrow(queryls) < 200) { queryls$group <- "FullList" }
if (nrow(queryls) > 201) { queryls$group <- c(rep("Top100_most_similar_sequences", each = 100),
                                              rep("rm", each = (nrow(queryls) - 200)),
                                              rep("Top100_most_different_sequences", each = 100)
) }

write.csv(queryls, paste0(plotdir, "FullTableDf.csv"))

write.csv(queryls, paste0(plotdir, "AlignmentTable.csv"))
system(paste0(" echo '", plotdir, "AlignmentTable.csv' >>", JobDir, "OutputList.csv"))

queryls$ProductID <- ifelse(nchar(queryls$ProductID) > 50, paste0(substr(queryls$ProductID, 1, 50), "..."), queryls$ProductID)

scoremat <- data.frame(ProteinID = paste0(queryls$protein_id, " ", queryls$ProductID),
                       dplyr::select(queryls, all_of(unique(rf$subject_id)))
)
scoremat$group <- queryls$group
scoremat <- subset(scoremat, !group == "rm")

scoremat$rows <- 1:nrow(scoremat)
scoremat$rowL <- ifelse(scoremat$rows < 51, "Sequences_1to50",
                        ifelse(scoremat$rows < 101, "Sequences_51to100",
                              ifelse(scoremat$rows < 151, "Sequences_101to150",
                                     ifelse(scoremat$rows < 201, "Sequences_151to200", scoremat$rows)

                              )))

scoremat$group2 <- paste0(scoremat$group, "_", scoremat$rowL)
scoremat$group <- scoremat$group2
scoremat$group2 <- NULL
scoremat$rowL <- NULL
scoremat$rows <- NULL

write.csv(scoremat, paste0(plotdir, "ScoreHeatmapDf.csv"), row.names = F)


CurrentRCode <- "HeatmapsFreeCode.R"
print(paste0(Sys.time(), " : starting ", CurrentRCode))




Input <- paste0(plotdir, "ScoreHeatmapDf.csv")
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

SpList <- c("group") # use # for skipping.

system(paste0("mkdir -p ", MainOutput, "SplitDatasets"))



DoZscores <- "no" #options "yes" "no"

HeatCol <- "default" #options "default" and "custom" for apply (brewer.pal(9, "YlGnBu")) or colorRampPalette(c("yellow1","yellow2","yellow3", "black","blue3","blue2","blue1")), respectively


source(paste0(ScriptsDir, "SplitDf_Heatmaps.R"))

system(paste0("cd ", MainOutput, "SplitDatasets", "; mkdir -p temp;cp *_Info.csv temp;cd temp;ls> list.csv"))
Infol <- read.csv(paste0(MainOutput, "SplitDatasets/temp/list.csv"), header = F)
Infol <- subset(Infol, !V1 == "list.csv")
Infol <- Infol$V1

for (myinfo in Infol) {
  FFInfo <- read.csv(paste0(MainOutput, "SplitDatasets/temp/", myinfo))

  source(paste0(ScriptsDir, "FFInfoCode.R"))

  newrow <- data.frame(X = "", Info = "DoZscores", Detail = DoZscores, Description = "", Requisites = "")
  FFInfo <- rbind(FFInfo, newrow)

  newrow <- data.frame(X = "", Info = " HeatCol", Detail = HeatCol, Description = "", Requisites = "")
  FFInfo <- rbind(FFInfo, newrow)

  source(paste0(ScriptsDir, "PreliminaryFreeSetup.R"))

  FF <- read.csv(Input)
  FF$ProteinID <- paste0(FF$ProteinID, "#", FF$X)
  FF$group <- NULL
  editfol <- Anfold
  source(paste0(ScriptsDir, "EditHeatmapDfCode.R"))

  cfol <- Anfold
  SumData_df <- paste0(Anfold, "EditDf_data.csv")

  MyScript <- "HeatmapCoreCode.R"

  starttext <- paste0(Sys.time(), ": starting ", MyScript)
  print(starttext)








  datafile <- SumData_df #skip this if doing optimization plot
  FF <- read.csv(datafile) #file



  system(paste0(" echo '", starttext, "\n",
                "'>>", cfol, "History.txt"))


  source(paste0(ScriptsDir, "ggplotSetting.R"))

  source(paste0(ScriptsDir, "FitPlotDescription.R"))


  hcolManual <- colorRampPalette(c("yellow1", "yellow2", "yellow3", "black", "blue3", "blue2", "blue1"))



  if (grepl("FullList_group", myinfo) == TRUE) { hcolYlGnBu <- colorRampPalette(brewer.pal(8, "Greens"))(nrow(FF)) }
  if (grepl("Top100_most_different", myinfo) == TRUE) { hcolYlGnBu <- colorRampPalette(brewer.pal(8, "Reds"))(nrow(FF)) }
  if (grepl("Top100_most_similar", myinfo) == TRUE) { hcolYlGnBu <- colorRampPalette(brewer.pal(8, "Blues"))(nrow(FF)) }


  if (DoZscores == "yes") { Myscale <- "row"
    col_breaks <- NULL }else { Myscale <- "none"
    col_breaks <- c(seq(-1, 0, length = 100),
                    seq(0.001, 1, length = 100))
  }


  analysisSpecifics <- ""
  if (DoZscores == "yes") { analysisSpecifics <- paste0(bname, "_Zscores") }
  myinfo

  PlotLabelName <- paste0(cfol, gsub("_group_Info.csv", ".pdf", myinfo))
  system(paste0(" echo '", PlotLabelName, "' >>", JobDir, "OutputList.csv"))


  d <- FF[2:ncol(FF)]
  row.names(d) <- FF$X

  psf <- read.csv(paste0(ScriptsDir, "PlotSize.csv"))
  psf <- subset(psf, !Info == "Info")
  names(psf) <- psf[1,]
  psf <- subset(psf, RowNo == ncol(FF))
  MyWidth <- as.numeric(as.character(psf$AreaSide))

  if (HeatCol == "default") { hcol <- hcolYlGnBu }
  if (HeatCol == "custom") { hcol <- hcolManual }


  dc <- d
  for (dcn in names(dc)) {
    dcr <- runif(nrow(dc), 0, 0.1)
    dc$rand <- dcr
    dc[[dcn]] <- dc[[dcn]] + dc$rand
  }


  pdf(PlotLabelName, height = MyHeight, width = MyWidth)
  out <- heatmap.2(as.matrix(dc),

                  lwid = c(1, 4),
                  lhei = c((MyWidth * 0.1), (MyWidth * 0.7)),
                   cexRow = 2,
                   cexCol = 2,
                   Colv = T,
                   srtCol = 45,
                   dendrogram = "both", #options "both","row","column","none"
                  col = hcol, #options hmcol=YlGnBu hcol=customized(see above)
                  scale = Myscale,
                   margin = c(40, 50),
                   trace = "none",
                   key = TRUE,
                  key.par = list(cex = 1.1),
                  key.title = "Mean Similarity Score (%)",
  )

  dev.off()

  endtext <- paste0(Sys.time(), ": ", MyScript, " done")
  print(endtext)

}


