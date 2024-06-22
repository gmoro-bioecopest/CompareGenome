library(stringr)


MyDescription2 <- paste0("Data description: ", MyDescription)
textsize <- as.numeric(as.character(MyWidth)) * 2.5 #default, till MyWidth=15

StartVec <- 0:7 * textsize + 1
StopVec <- 1:8 * textsize
MyDescription <- data.frame(str_sub(string = MyDescription2, start = StartVec, end = StopVec)); names(MyDescription) <- "C"; MyDescription <- subset(MyDescription, !C == "")
MyDescription <- paste(MyDescription$C, collapse = "\n")

errbarNote2 <- errbarNote
StartVec <- 0:7 * textsize + 1
StopVec <- 1:8 * textsize
errbarNote <- data.frame(str_sub(string = errbarNote2, start = StartVec, end = StopVec)); names(errbarNote) <- "C"; errbarNote <- subset(errbarNote, !C == "")
errbarNote <- paste(errbarNote$C, collapse = "\n")

dfnote2 <- paste0("Dataset: ", datafile)
StartVec <- 0:7 * textsize + 1
StopVec <- 1:8 * textsize
dfnote <- data.frame(str_sub(string = dfnote2, start = StartVec, end = StopVec)); names(dfnote) <- "C"; dfnote <- subset(dfnote, !C == "")
dfnote <- paste(dfnote$C, collapse = "\n")

MyCaption <- paste0("Date: ", Sys.time(), "\nR code : ", MyScript, "\n", MyDescription, "\n", errbarNote, "\n", dfnote)

system(paste0("echo '", MyCaption, "' >", cfol, "MyCaption.txt"))

MyCaptionlenght <- read.csv(paste0(cfol, "MyCaption.txt"), header = F)
MyCaptionlenght <- nrow(MyCaptionlenght)
