if (!"Treatment" %in% names(loopf)) {
  loopf$Treatment <- "Default"
}

if (!"LinePlotX" %in% names(loopf)) {
  loopf$LinePlotX <- "Default"
}
if (!"Replicate" %in% names(loopf)) {
  loopf$Replicate <- 1
}

if (!"PlotOrder" %in% names(loopf)) {
  loopf$PlotOrder <- 1 #if want alphabetical order use loopf$PlotOrder=1
}


if (!"LinePlotXOrder" %in% names(loopf)) {
  loopf$LinePlotXOrder <- 1    #if want alphabetical order use loopf$LinePlotXOrder=1
}

if (!"LinePlotLines" %in% names(loopf)) {
  loopf$LinePlotLines <- "Default" #if not present and not necessary use loopf$LinePlotLines="Default"
}
if (!"Data" %in% names(loopf)) {
  loopf$Data <- "Data"
}

SpList <- c("Data")
