args <- commandArgs(trailingOnly = TRUE)

library(ggplot2)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

mypattern <- "BlastComparison"
analysisdir <- paste0(MyDir, mypattern, "/")
system(paste0("mkdir -p ", analysisdir))

system(paste0("cd ", MyDir, "Phylogeny/OutputFiles;find $PWD -type f -name '*_Vs_RefSeq_TopBitScore.csv' >", analysisdir, "TopBitScoreList.txt"))
scorel <- read.table(paste0(analysisdir, "TopBitScoreList.txt"))

for (score in scorel$V1) {
 scorefile <- read.csv(score, check.names = F)
  scorefile$Coverage <- ifelse(scorefile$`%_ofSubjectCovered` > 100, 100, scorefile$`%_ofSubjectCovered`)
  scorefile$Score <- scorefile$`%_identity` * (scorefile$Coverage / 100)
  scorefile$Row <- 1:nrow(scorefile)
  scorefile$ScoreGroup <- ""
  for (i in scorefile$subject_id) {

    subfile <- subset(scorefile, subject_id == i)
    subscore <- subfile$Score
    subsrow <- subfile$Row
    if (subscore > 99) { groupid <- "Score_99_to_100" }
    if (subscore > 95 & subscore < 99) { groupid <- "Score_95_to_99" }
    if (subscore > 90 & subscore < 95) { groupid <- "Score_90_to_95" }
    if (subscore > 80 & subscore < 90) { groupid <- "Score_80_to_90" }
    if (subscore > 70 & subscore < 80) { groupid <- "Score_70_to_80" }
    if (subscore > 0 & subscore < 70) { groupid <- "Score_0_to_70" }

    scorefile[subsrow, "ScoreGroup"] <- groupid
  }

  folder <- gsub(".*/", "", score)
  folder <- gsub("_Vs_RefSeq_TopBitScore.csv", "", folder)
  folder
  system(paste0("mkdir -p ", analysisdir, folder))
  write.csv(scorefile, paste0(analysisdir, folder, "/scorefile.csv"))


  scoresummary <- Rmisc::summarySE(data = scorefile, measurevar = "Score",  
                                  groupvars = "ScoreGroup")

  scoresummary$ID <- folder

  write.csv(scoresummary, paste0(analysisdir, folder, "/scoresummary.csv"))
}

system(paste0("cd ", analysisdir, "; cat ./*/scoresummary.csv >FullSummary.csv"))
fullsum <- read.csv(paste0(analysisdir, "FullSummary.csv"))
fullsum <- subset(fullsum, !N == "N")

SummaryDf <- fullsum
SummaryDf$X_Axis <- SummaryDf$ID
SummaryDf$N <- SummaryDf$N
SummaryDf$Y_Axis <- SummaryDf$Score
SummaryDf$sd <- 1
SummaryDf$se <- 1
SummaryDf$ci <- 1
SummaryDf$XaxisOrder <- SummaryDf$ci
SummaryDf$Label <- ""

write.csv(SummaryDf, paste0(analysisdir, "PlotDf.csv"))


cfol <- analysisdir
Anfold <- analysisdir
SumData_df <- paste0(Anfold, "PlotDf.csv")

FFInfo <- data.frame(X = "", Info = c("ScriptsDir",
                                      "TempDir",
                                      "Input",
                                      "Output"))
FFInfo$Detail <- c(ScriptsDir, TempDir,
                   SumData_df,
                   analysisdir)
FFInfo$Description <- ""
FFInfo$Requisites <- ""

newrow <- data.frame(X = "", Info = "TrasposePlot", Detail = "yes", Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

newrow <- data.frame(X = "", Info = "Y_label", Detail = "", Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

MyDescription <- "Occurrence of GO terms per pathway. Shown positively (number of genes>than expected) enriched pathways (P<0.05, Chi-square test)."
newrow <- data.frame(X = "", Info = "MyDescription", Detail = MyDescription, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

Y_angle <- 0
newrow <- data.frame(X = "", Info = "Y_angle", Detail = Y_angle, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

X_angle <- 0
newrow <- data.frame(X = "", Info = "X_angle", Detail = X_angle, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

write.csv(FFInfo, paste0(cfol, "FFInfo.csv"))

MyScript <- "BarPlotCoreCode.R"

starttext <- paste0(Sys.time(), ": starting ", MyScript)
print(starttext)


datafile <- SumData_df
FF <- read.csv(datafile)

system(paste0(" echo '", starttext, "\n",
              "'>>", cfol, "History.txt"))


source(paste0(ScriptsDir, "ggplotSetting.R"))

source(paste0(ScriptsDir, "FitPlotDescription.R"))


FF$Newlabels <- FF$ScoreGroup
FF$Newlabels <- gsub("Score_", "", FF$Newlabels)
FF$Newlabels <- gsub("_", " ", FF$Newlabels)
FF$Newlabels <- paste0(FF$Newlabels, "%")
FF$Newlabels <- gsub(" to ", "-", FF$Newlabels)

PlotOpt1 <- ggplot(FF, aes(x = reorder(X_Axis, XaxisOrder), y = N, fill = Newlabels)) +

  theme(
    plot.title = MyTitleSetting,
    plot.subtitle = MySubTitleSetting,
    plot.caption = MyCaptionSetting) +
  geom_bar(stat = "identity", position = "stack", width = 0.5, size = 1) + #details of border and filling

  theme(
    axis.title = MyAxisTitleSetting,
    axis.text.x = MyAxisX_Setting,
    axis.text.y = MyAxisY_Setting,
    axis.ticks = MyAxisTicks_Setting,
    axis.line = MyAxisLine_Setting) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"),
        plot.background = element_rect(color = "white", fill = "white")) +

  theme(aspect.ratio = 1.1) + #it will increase/decrease plot width

  theme(legend.direction = "vertical",
        legend.box = "vertical",
        legend.position = "right",
        legend.justification = c(0.5, 1),
        legend.text = element_text(margin = margin(t = 0), size = YaxisSize),
        legend.spacing.x = unit(0.3, 'cm')) +
  ylab(paste0("\nNumber of sequences aligned to the reference genome")) +
  xlab(paste0("")) +
  guides(fill = guide_legend(title = "Identity Score")) +
  theme(legend.title = element_text(size = YaxisSize, face = "bold"))


FigNo <- "Fig"
bname <- ""

analysisSpecifics <- bname
PlotLabelName <- paste0(cfol, FigNo, analysisSpecifics, "_barplot.pdf")


length(dev.list())
if (length(dev.list()) > 0) { dev.off() }

if (TrasposePlot == "yes") {

  MyPlot <- PlotOpt1 +
    coord_flip() +
    labs(title = "",
         subtitle = "",
         colours = "test")
  print(MyPlot, ncol = 1)

}else {
  MyPlot <- PlotOpt1 +
    labs(title = "",
         subtitle = "",
         colours = "test")
  print(MyPlot, ncol = 1)


}
ggsave(
  PlotLabelName,
  plot = MyPlot,

  width = MyWidth,
  height = MyHeight

)


endtext <- paste0(Sys.time(), ": ", MyScript, " done")
print(endtext)


system(paste0(" echo '", endtext, "\n",
              "'>>", cfol, "History.txt"))
