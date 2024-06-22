

print(paste0(Sys.time(), ": starting EditDfCode.R"))
system(paste0("rm -rf ", TempDir, "*"))


Cformat <- unique(FF[[1]])
Cformat2 <- data.frame(A = Cformat)

if ("Info" %in% Cformat2$A) {
  FF <- subset(FF, !Info == "Info") #remove info
  names(FF) <- FF[1,]   #rename
  FF <- FF[-c(1),] #remove first row
}

ll <- c("Treatment", "Replicate", "PlotOrder",
        "LinePlotX", "LinePlotXOrder", "LinePlotLines") #do not include observation
MyDataset <- FF[, colnames(FF) %in% ll]

ObservationList1 <- data.frame(FF[, grepl(paste("Observation", collapse = "|"), names(FF))])
if (ncol(ObservationList1) == 1) { names(ObservationList1) <- "Observation1" }
MyDataset2 <- cbind(MyDataset, ObservationList1)

ll2 <- names(ObservationList1)
if (length(ll2) > 1) { ObsList <- MyDataset2[, grepl(paste(ll2, collapse = "|"), names(MyDataset2))]
  ObsList <- colnames(ObsList) }else { ObsList <- ll2 }

for (Obs in ObsList) {
  MyObs <- data.frame(MyDataset, ObservationValue = MyDataset2[Obs], ObsID = Obs)
  colnames(MyObs) <- c(names(MyDataset), "ObservationValue", "ObsID")

  write.csv(MyObs, paste0(TempDir, "ObservationValue", Obs, ".csv")) }

ObsNames <- c(names(MyDataset), "ObservationValue", "ObsID")
system(paste0("cd ", TempDir, "; cat ObservationValue*.csv >AllObservations.csv"))


AllObservations <- read.csv(paste0(TempDir, "AllObservations.csv"))
ll4 <- ObsNames
AllObservations <- AllObservations[, grepl(paste(ll4, collapse = "|"), names(AllObservations))]
AllObservations <- subset(AllObservations, !Treatment == "Treatment")
RemovedValues <- subset(AllObservations, ObservationValue == "empty")

if (nrow(RemovedValues) > 0) {
  system(paste0(" echo '", nrow(RemovedValues), " of total ", (nrow(AllObservations) - nrow(RemovedValues)),
                " values were removed because labelled as empty\n",
                "'>>", editfol, "Warnings.txt"))
}

AllObservations <- subset(AllObservations, !ObservationValue == "empty")

system(paste0("rm -rf ", TempDir, "*"))

EnvList <- data.frame(ls()); names(EnvList) <- "list"

if ("editfol" %in% EnvList$list) {
  EditDf_data <- AllObservations
  write.csv(EditDf_data, paste0(editfol, "EditDf_data.csv"))
}else { print(paste0(Sys.time(), ": ERROR: editfol is missing, EditDf_data.csv cannot be saved ")) }

print(paste0(Sys.time(), ": EditDfCode.R done"))

