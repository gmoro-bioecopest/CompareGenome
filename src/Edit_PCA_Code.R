

print(paste0(Sys.time(), ": starting Edit_PCA_Code"))
system(paste0("rm -rf ", TempDir, "*"))


Cformat <- unique(FF[[1]])
Cformat2 <- data.frame(A = Cformat)

if ("Info" %in% Cformat2$A) {
  FF <- subset(FF, !Info == "Info") #remove info
  names(FF) <- FF[1,]   #rename
  FF <- FF[-c(1),] #remove first row
}


GrepObs <- ObsList


MyDataset <- data.frame(Observation = FF[mainFact])
ll <- GrepObs

ObservationList1 <- data.frame(FF[, grepl(paste(ll, collapse = "|"), names(FF))])
if (ncol(ObservationList1) == 1) { names(ObservationList1) <- "Observation1" }
MyDataset2 <- cbind(MyDataset, ObservationList1)
MyDataset <- MyDataset2

MyDatasetOrig <- MyDataset
MainFactor <- names(MyDatasetOrig[1])
Observation <- names(MyDatasetOrig[2:ncol(MyDatasetOrig)])

ll <- c(MainFactor, Observation)

MyDataset <- MyDataset[, grepl(paste(ll, collapse = "|"), names(MyDataset))]

MyDataset <- MyDataset[, ll]

MyListTT <- data.frame(MyDataset[MainFactor])
colnames(MyListTT) <- "gene"
pasillaCountTable <- data.frame(t(MyDataset), check.names = F)
colnames(pasillaCountTable) <- MyListTT$gene
pasillaCountTable <- pasillaCountTable[-1,]
MyDataset <- pasillaCountTable
MyOldLabel <- rownames(MyDataset)

NameMatch2 <- as.data.frame(NameMatch[3:nrow(NameMatch),])
write.csv(NameMatch2, paste0(analysisdir, "nmtempfile.csv"), row.names = F)
NameMatch2 <- read.csv(paste0(analysisdir, "nmtempfile.csv"))

names(NameMatch2) <- c("old", "new")

nrow(NameMatch2)
group1 <- round(nrow(NameMatch2) / 2, 0)
group2 <- nrow(NameMatch2) - group1

datasheet1 <- data.frame(OldLabel = NameMatch2$old,
                         NewLabel = NameMatch2$new,
                         Group = c(rep("Group1", each = group1), rep("Group2", each = group2)),
                         Selection = "y",
                         FolderName = c("AllSamples", rep("", each = (nrow(MyDataset) - 1))),
                         Description = c("Skipthis", rep("", each = (nrow(MyDataset) - 1))))
names(datasheet1) <- c("OldLabel", "NewLabel", "Group", "Selection", "FolderName", "Description")

write.csv(datasheet1, paste0(MyDir, "PCA_SETUP.csv"), row.names = F)
X_labels <- ""
Y_labels <- ""


resMyDataset <- MyDataset


MyDataset <- resMyDataset
AnalysisDetails <- read.csv(paste0(MyDir, "PCA_SETUP.csv"))
split <- "Setting1"
tempID <- subset(AnalysisDetails, !FolderName == "")

ID <- as.character(tempID$FolderName)
MyDescription <- as.character(tempID$Description)

AnalysisDetails$FolderName <- NULL
AnalysisDetails$Description <- NULL


MyDataset$OldLabel <- rownames(MyDataset)
MySelDf <- merge(MyDataset, AnalysisDetails, by = "OldLabel", all = F)
rownames(MySelDf) <- MySelDf$OldLabel
MySelDf$OldLabel <- NULL

MySelDf <- subset(MySelDf, Selection == "y") #subset to keep selected rows only

MyDirID <- paste0(MyDir, ID, "_", split, "/")
FoldCheck <- list.files(path = MyDir, pattern = paste0(ID, "_", split))
if (length(FoldCheck) == 1) { print(paste0(split, " already analyzed")) }else { system(paste0("mkdir -p ", MyDirID))

  pasillaCountTable <- MySelDf
  rownames(pasillaCountTable) <- pasillaCountTable$NewLabel
  ll <- c("OldLabel", "NewLabel", "Group", "Selection")
  pasillaCountTable <- pasillaCountTable[, !grepl(paste(ll, collapse = "|"), names(pasillaCountTable))]
  pasillaCountTable <- data.frame(t(pasillaCountTable), check.names = F)

  tpasil <- data.frame(remove = 1:nrow(pasillaCountTable))
  rownames(tpasil) <- rownames(pasillaCountTable)

  for (cn in colnames(pasillaCountTable)) {
    spasil <- dplyr::select(pasillaCountTable, all_of(cn))
    colnames(spasil) <- "col"
    spasil$col <- as.numeric(as.character(spasil$col))
    colnames(spasil) <- cn
    tpasil <- cbind(tpasil, spasil)
  }
  tpasil$remove <- NULL
  pasillaCountTable <- tpasil


  pasillaDesign <- data.frame(row.names = MySelDf$NewLabel,
                              condition = MySelDf$Group,
                              libType = rep("double-end", each = nrow(MySelDf))
  )
  dds <- pasillaCountTable
  MyTreshold <- 0

  y <- dds
  data <- prcomp(y, scale = T)

  save(y, data, MyTreshold, Anfold, file = paste0(MyDirID, "EditDf_data.RData"))


}


system(paste0("rm -rf ", TempDir, "*"))

print(paste0(Sys.time(), ": Edit_PCA_Code.R done"))

