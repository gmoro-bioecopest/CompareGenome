

print(paste0(Sys.time(), ": starting EditHeatmapDfCode.R"))
system(paste0("rm -rf ", TempDir, "*"))


Cformat <- unique(FF[[1]])
Cformat2 <- data.frame(A = Cformat)

if ("Info" %in% Cformat2$A) {
  FF <- subset(FF, !Info == "Info") #remove info
  names(FF) <- FF[1,]   #rename
  FF <- FF[-c(1),] #remove first row
}

ll <- mainFact #do not include observation
MyDataset <- FF[ll]

ObservationList1 <- data.frame(FF[, grepl(paste(ObsList, collapse = "|"), names(FF))])
if (ncol(ObservationList1) == 1) { names(ObservationList1) <- "Observation1" }
MyDataset2 <- ObservationList1
row.names(MyDataset2) <- FF[[ll]]

MyDataset2$dup <- row.names(MyDataset2)
MyDataset2 <- MyDataset2[!duplicated(MyDataset2[, c("dup")]),]
MyDataset2$dup <- NULL
names(MyDataset2)


system(paste0("rm -rf ", TempDir, "*"))

EnvList <- data.frame(ls()); names(EnvList) <- "list"

if ("editfol" %in% EnvList$list) {
  EditDf_data <- MyDataset2
  write.csv(EditDf_data, paste0(editfol, "EditDf_data.csv"))
}else { print(paste0(Sys.time(), ": ERROR: editfol is missing, EditDf_data.csv cannot be saved ")) }

print(paste0(Sys.time(), ": EditHeatmapDfCode.R done"))

