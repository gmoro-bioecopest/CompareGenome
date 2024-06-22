

MyScript <- "EnrichmentFreeCode.R"

starttext <- paste0(Sys.time(), ": starting ", MyScript)
print(starttext)






Threshold <- 0 #value<than this will be removed
ObtainedData <- subset(ObtainedData, !Obtained < Threshold)

enrdf <- data.frame(Factor = "rm", ObservedValue = "rm", ObservedTotal = "rm", ReferenceValue = "rm", ReferenceTotal = "rm", ObservedFrequency = "", ExpectedFrequency = "", EnrType = "", Fisher = "rm")


for (i in ObtainedData$List) {
  obt <- subset(ObtainedData, List == i)
  obtCount <- obt$Obtained
  obtTotal <- obt$Total - obtCount
  refs <- subset(ReferenceData, List == i)
  refsCount <- refs$ReferenceData
  refsTotal <- refs$Total - refsCount

  ObservedFrequency <- (obtCount / obt$Total) * 100
  ExpectedFrequency <- (refsCount / refs$Total) * 100
  if (ObservedFrequency > ExpectedFrequency) { EnrType <- "greater" }else { EnrType <- "lower" }


  M <- as.table(rbind(c(obtCount, refsCount), c((obtTotal - obtCount), (refsTotal - refsCount))))
  dimnames(M) <- list(Significant = c("Y", "N"),
                      Values = c("Observed", "Reference"))
  M1 <- as.data.frame(M)
  (Xsq <- fisher.test(M))  # Prints test summary
  Pvalue <- Xsq$p.value

  newrow <- data.frame(Factor = i, ObservedValue = obtCount, ObservedTotal = obt$Total, ReferenceValue = refsCount, ReferenceTotal = refs$Total, ObservedFrequency = ObservedFrequency, ExpectedFrequency = ExpectedFrequency, EnrType = EnrType, Fisher = Pvalue)
  enrdf <- rbind(enrdf, newrow)

}


SummaryDf <- subset(enrdf, !Factor == "rm")
SummaryDf$ObservedValue <- as.numeric(as.character(SummaryDf$ObservedValue))
SummaryDf$X_Axis <- SummaryDf$Factor
SummaryDf$N <- SummaryDf$ObservedValue
SummaryDf$Y_Axis <- SummaryDf$ObservedValue
SummaryDf$sd <- 1
SummaryDf$se <- 1
SummaryDf$ci <- 1
SummaryDf$XaxisOrder <- SummaryDf$ObservedValue
SummaryDf$Label <- ""

write.csv(SummaryDf, paste0(Anfold, "FullEnrichementAnalysis.csv"))

SummaryDf$P_value <- as.numeric(as.character(SummaryDf$Fisher))
SummaryDf <- subset(SummaryDf, P_value < 0.05)
SummaryDf <- subset(SummaryDf, EnrType == "greater")

write.csv(SummaryDf, paste0(Anfold, "PositivelyEnrichedOnly.csv"))

cfol <- Anfold
SumData_df <- paste0(Anfold, "PositivelyEnrichedOnly.csv")

newrow <- data.frame(X = "", Info = "TrasposePlot", Detail = "no", Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

newrow <- data.frame(X = "", Info = "Y_label", Detail = "Number of sequences/GO term", Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

MyDescription <- "Occurren of GO terms per pathway. Shown positively (number of genes>than expected) enriched pathways (P<0.05, Chi-square test)."
newrow <- data.frame(X = "", Info = "MyDescription", Detail = MyDescription, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

Y_angle <- 0
newrow <- data.frame(X = "", Info = "Y_angle", Detail = Y_angle, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

X_angle <- 0
newrow <- data.frame(X = "", Info = "X_angle", Detail = X_angle, Description = "", Requisites = "")
FFInfo <- rbind(FFInfo, newrow)

write.csv(FFInfo, paste0(cfol, "FFInfo.csv"))



