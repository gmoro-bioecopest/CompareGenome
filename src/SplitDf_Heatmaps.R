CRC <- gsub("Code.R", "Output", CurrentRCode)
AnalysisInfoCheck <- data.frame(V1 = list.files(path = MyDir, pattern = CRC))
CRC <- paste0(CRC, "_", (nrow(AnalysisInfoCheck) + 1), "/")

system(paste0("mkdir -p ", MainOutput, CRC))

for (i in ObsList) {
  newcol <- paste0(i, "_ColumnToRemove")
  loopf[[newcol]] <- "remove"
}

ObsList2 <- ObsList
myobs <- "group"
split <- "group"
for (subf in unique(loopf[[split]])) { #select here the column to address the splitting
  loopf$split <- loopf[[split]]
  loopfs <- subset(loopf, split == subf) #select here the column to address the subsetting

  subfolder <- paste0(subf, "/")
  if (subf == "Data") { subfolder <- "AllData/" }
  system(paste0("mkdir -p ", MainOutput, CRC, subfolder))
  subfolder2 <- paste0(myobs, "/")
  if (subf == "Observation") { subfolder2 <- "RawData/" }
  system(paste0("mkdir -p ", MainOutput, CRC, subfolder, subfolder2))

  finalfolder <- paste0(MainOutput, CRC, subfolder, subfolder2)

  if (subf == "Data") { subf2 <- "AllData" }else { subf2 <- subf }

  if (myobs == "Observation") { myobs2 <- "RawData" }else { myobs2 <- myobs } #changed 14/01/2022: myobs2="RawData" instead of myobs="RawData"

  splitDfID <- paste0(subf2, "_", myobs2, "_Df.csv") #dataset full path
  splitDfIDinfo <- paste0(subf2, "_", myobs2, "_Info.csv") #infofile full path

  loopfs$group <- NULL
  loopfs2 <- loopfs
  for (i in names(loopfs2)) {
    loopfs2s <- dplyr::select(loopfs2, all_of(i))
    if (length(grep("_ColumnToRemove", names(loopfs2s))) == 1) { loopfs2[[i]] <- NULL }
  }
  write.csv(loopfs2, paste0(MainOutput, "SplitDatasets/", splitDfID))
  Input <- paste0(MainOutput, "SplitDatasets/", splitDfID)
  FFInfo <- read.csv(Infofile)
  FFInfo <- subset(FFInfo, !Info == "Input")
  newrow <- data.frame(X = "", Info = "Input", Detail = Input, Description = "", Requisites = "")
  FFInfo <- rbind(FFInfo, newrow)
  newrow <- data.frame(X = "", Info = "Output", Detail = finalfolder, Description = "", Requisites = "")
  FFInfo <- rbind(FFInfo, newrow)

  FFInfo$X <- NULL
  write.csv(FFInfo, paste0(MainOutput, "SplitDatasets/", splitDfIDinfo))

  FFInfo <- read.csv(Infofile)
  newrow <- data.frame(X = "", Info = "Output", Detail = finalfolder, Description = "", Requisites = "")
  FFInfo <- rbind(FFInfo, newrow)
}



