


charToRemove <- read.csv(paste0(ScriptsDir, "CleanHeaders.csv"))
charToRemove <- subset(charToRemove, !Info == "Info")
names(charToRemove) <- charToRemove[1,]
charToRemove <- charToRemove[-1,]

cldf <- data.frame(oldlab = t(toclean))
names(cldf) <- "oldlabel"
cldf$newlabel <- cldf$oldlabel

for (symb in charToRemove$Symbol) {
  subsymb <- subset(charToRemove, Symbol == symb)
  old <- symb
  new <- subsymb$Label
  cldf$newlabel <- gsub(old, "", cldf$newlabel, fixed = TRUE)
}

toclean <- cldf$newlabel


