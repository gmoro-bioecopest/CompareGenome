

Infofile <- data.frame(Info = c("ScriptsDir", "TempDir", "Input", "MainOutput"),
                       Detail = c(ScriptsDir, TempDir, Input, MainOutput),
                       Description = c("directory of single analysis codes. no pipeline should be in there",
                                      "directory for temporary outputs",
                                      "full path of the properly formatted file. look at DataAnalysisDf.csv for details",
                                      "main output path"),
                       Requisites = c("Mandatory", "Mandatory", "Mandatory", "Mandatory"))

write.csv(Infofile, paste0(MainOutput, "Infofile.csv"))
Infofile <- paste0(MainOutput, "Infofile.csv")

loopf <- read.csv(Input, check.names = F)
loopf[1] <- NULL
loopf[1] <- NULL
loopf[1] <- NULL


if ("Info" %in% names(loopf)) {
  InfoData <- data.frame(V1 = unique(loopf$Info))

  if ("Info" %in% unique(InfoData$V1) | "Data" %in% unique(InfoData$V1)) { dothis <- "y" }

  if (dothis == "y") {
    loopf <- subset(loopf, !Info == "Info") #remove info
    names(loopf) <- loopf[1,]   #rename
    loopf <- loopf[-c(1),] #remove first row

  }

}
dothis <- "n" #set the default again

FFInfo <- read.csv(Infofile)
