args <- commandArgs(trailingOnly = TRUE)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")



if (file.size(paste0(JobDir, "features/cds_geneID.csv")) == 0 | file.size(paste0(JobDir, "features/gene_geneID.csv")) == 0) { print("no folders with ID into geneID") }else {
  cdsl <- read.csv(paste0(JobDir, "features/cds_geneID.csv"), header = F)
  genel <- read.csv(paste0(JobDir, "features/gene_geneID.csv"), header = F)


  cdsl$file <- gsub(".*/", "", cdsl$V1)
  filel <- unique(cdsl$file)
  cdsl$fol <- cdsl$V1
  for (fl in filel) {
    cdsl$fol <- gsub(fl, "", cdsl$fol)
  }

  cdsl$row <- 1:nrow(cdsl)
  cdsl$ID1 <- ""
  for (r in cdsl$row) {
    cdsub <- subset(cdsl, row == r)
    ID1 <- read.table(cdsub$V1)
    ID1 <- ID1$V1
    cdsl[r, "ID1"] <- ID1
  }

  genel$row <- 1:nrow(genel)
  genel$ID2 <- ""
  for (r in genel$row) {
    cdsub <- subset(genel, row == r)
    ID2 <- read.table(cdsub$V1)
    ID2 <- ID2$V1
    genel[r, "ID2"] <- ID2

  }

  genel$file <- gsub(".*/", "", genel$V1)
  filel <- unique(genel$file)
  genel$fol <- genel$V1
  for (fl in filel) {
    genel$fol <- gsub(fl, "", genel$fol)
  }

  genel$genefol <- genel$fol
  genel$ID <- genel$ID2


  cdsl$cdsfol <- cdsl$fol
  cdsl$ID <- cdsl$ID1

  cdsl$sel <- ifelse(cdsl$ID %in% genel$ID, "y", "n")
  cdsl <- subset(cdsl, sel == "y")

  test <- merge(cdsl, genel, by = "ID", all = F)
  write.csv(test, paste0(JobDir, "test.csv"))

  if (nrow(test) > 0) {
    for (move in test$ID) {
      subtest <- subset(test, ID == move)
      genefol <- subtest$genefol
      cdsfol <- subtest$cdsfol
      system(paste0("cd ", JobDir, "features; mv ", genefol, "/* ", cdsfol, ";rm -rf ", genefol))
    }
  }


}



if (file.size(paste0(JobDir, "features/cds_locus_tag.csv")) == 0 | file.size(paste0(JobDir, "features/gene_locus_tag.csv")) == 0) { print("no folders with ID into locus_tag") }else {

  genel <- read.csv(paste0(JobDir, "features/gene_locus_tag.csv"), header = F)
  cdsl <- read.csv(paste0(JobDir, "features/cds_locus_tag.csv"), header = F)

  cdsl$file <- gsub(".*/", "", cdsl$V1)
  filel <- unique(cdsl$file)
  cdsl$fol <- cdsl$V1
  for (fl in filel) {
    cdsl$fol <- gsub(fl, "", cdsl$fol)
  }

  cdsl$row <- 1:nrow(cdsl)
  cdsl$ID1 <- ""
  for (r in cdsl$row) {
    cdsub <- subset(cdsl, row == r)
    ID1 <- read.table(cdsub$V1)
    ID1 <- ID1$V1
    cdsl[r, "ID1"] <- ID1
    if (length(ID1) > 0) { cdsl[r, "ID1"] <- ID1 }
  }


  genel$row <- 1:nrow(genel)
  genel$ID2 <- ""
  for (r in genel$row) {
    cdsub <- subset(genel, row == r)
    ID2 <- read.table(cdsub$V1)
    ID2 <- ID2$V1
    if (length(ID2) > 0) { genel[r, "ID2"] <- ID2 }else { genel[r, "ID2"] <- "noMatch" }
  }

  genel$file <- gsub(".*/", "", genel$V1)
  filel <- unique(genel$file)
  genel$fol <- genel$V1
  for (fl in filel) {
    genel$fol <- gsub(fl, "", genel$fol)
  }

  genel$genefol <- genel$fol
  genel$ID <- genel$ID2

  cdsl$cdsfol <- cdsl$fol
  cdsl$ID <- cdsl$ID1

  cdsl$sel <- ifelse(cdsl$ID %in% genel$ID, "y", "n")
  cdsl <- subset(cdsl, sel == "y")

  test <- merge(cdsl, genel, by = "ID", all = F)
  write.csv(test, paste0(JobDir, "test.csv"))

  if (nrow(test) > 0) {
    for (move in test$ID) {
      subtest <- subset(test, ID == move)
      genefol <- subtest$genefol
      cdsfol <- subtest$cdsfol
      system(paste0("cd ", JobDir, "features; mv ", genefol, "/* ", cdsfol, ";rm -rf ", genefol))
    }
  }

}





if (file.size(paste0(JobDir, "features/cds_db_xref.csv")) == 0 | file.size(paste0(JobDir, "features/gene_db_xref.csv")) == 0) { print("no folders with ID into db_xref") }else {

  cdsl <- read.csv(paste0(JobDir, "features/cds_db_xref.csv"), header = F)
  genel <- read.csv(paste0(JobDir, "features/gene_db_xref.csv"), header = F)


  cdsl$file <- gsub(".*/", "", cdsl$V1)
  filel <- unique(cdsl$file)
  cdsl$fol <- cdsl$V1
  for (fl in filel) {
    cdsl$fol <- gsub(fl, "", cdsl$fol)
  }

  cdsl$row <- 1:nrow(cdsl)
  cdsl$ID1 <- ""
  for (r in cdsl$row) {
    cdsub <- subset(cdsl, row == r)
    ID1 <- read.table(cdsub$V1)
    ID1$sel <- ifelse(grepl("GeneID:", ID1$V1), "y", "n")
    ID1 <- subset(ID1, sel == "y")
    ID1 <- ID1$V1
    if (length(ID1) > 0) { cdsl[r, "ID1"] <- ID1 }

  }


  genel$row <- 1:nrow(genel)
  genel$ID2 <- ""
  for (r in genel$row) {
    cdsub <- subset(genel, row == r)
    ID2 <- read.table(cdsub$V1)
    ID2$sel <- ifelse(grepl("GeneID:", ID2$V1), "y", "n")
    ID2 <- subset(ID2, sel == "y")
    ID2 <- ID2$V1
    if (length(ID2) > 0) { genel[r, "ID2"] <- ID2 }else { genel[r, "ID2"] <- "noMatch" }
  }

  genel$file <- gsub(".*/", "", genel$V1)
  filel <- unique(genel$file)
  genel$fol <- genel$V1
  for (fl in filel) {
    genel$fol <- gsub(fl, "", genel$fol)
  }

  genel$genefol <- genel$fol
  genel$ID <- genel$ID2

  cdsl$cdsfol <- cdsl$fol
  cdsl$ID <- cdsl$ID1

  cdsl$sel <- ifelse(cdsl$ID %in% genel$ID, "y", "n")
  cdsl <- subset(cdsl, sel == "y")

  test <- merge(cdsl, genel, by = "ID", all = F)
  write.csv(test, paste0(JobDir, "test.csv"))

  if (nrow(test) > 0) {
    for (move in test$ID) {
      subtest <- subset(test, ID == move)
      genefol <- subtest$genefol
      cdsfol <- subtest$cdsfol
      system(paste0("cd ", JobDir, "features; mv ", genefol, "/* ", cdsfol, ";rm -rf ", genefol))
    }
  }

}



numb <- read.csv(paste0(JobDir, "features/CDS_NumberID.csv"), header = F)
numdf <- data.frame(V1 = 0)
for (num in numb$V1) {
  subnum <- read.table(num)
  numdf <- rbind(numdf, subnum)
}
topnum <- max(numdf$V1)





