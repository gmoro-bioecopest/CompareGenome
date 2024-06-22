args <- commandArgs(trailingOnly = TRUE)

library(dplyr)
library(ggplot2)
ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

library(GO.db)
goterms <- data.frame(GOID(GOTERM), Ontology(GOTERM), Term(GOTERM), Definition(GOTERM))
names(goterms) <- c("GOID", "ONTOLOGY", "TERM", "DEFINITION")
goterms <- subset(goterms, !GOID == "all")
write.csv(goterms, paste0(ScriptsDir, "goterms.csv"))
myfeat <- paste(goterms$GOID, collapse = "\n")
system(paste0("cd ", ScriptsDir, "; echo '", myfeat, "' >goterms.txt"))




