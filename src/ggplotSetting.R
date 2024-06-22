mainplotscript <- MyScript

source(paste0(ScriptsDir, "DefaultPlotSetup.R"))

InfoAvailable <- FFInfo
for (FInfoN in InfoAvailable$Info) {
  FFInfoTemp <- subset(FFInfo, Info == FInfoN)
  MyFinName <- paste0("'", FFInfoTemp$Detail, "'")
  FInfoV <- paste0(FInfoN, '=', MyFinName)
  eval(parse(text = FInfoV))
}


dothis <- "no" #set no as default
if (errbar %in% names(FF)) { dothis <- "yes" }

if (dothis == "yes") {
  if (errbar == "se") {
    FF$LowValue <- FF$Y_Axis - FF$se
    FF$TopValue <- FF$Y_Axis + FF$se
    errbarNote <- paste0("Error bars according with standard error")
    MyGeomText <- geom_text(aes(label = Label, y = (Y_Axis + se)), position = "stack", vjust = -0.5, hjust = 0.5, size = 10, angle = MyAngleLabels)
  }
  if (errbar == "sd") {
    FF$LowValue <- FF$Y_Axis - FF$sd
    FF$TopValue <- FF$Y_Axis + FF$sd
    errbarNote <- paste0("Error bars according with standard deviation")
    MyGeomText <- geom_text(aes(label = Label, y = (Y_Axis + sd)), position = "stack", vjust = -0.5, hjust = 0.5, size = 10, angle = MyAngleLabels)

  }
}


if (AlphaPlot == "yes") {
  FF <- FF[order(FF$X_Axis, decreasing = F),]
  FF$XaxisOrder <- 1:nrow(FF)
}

dothis <- "no" #set no as default
if ("X_angle" %in% FFInfo$Info) { dothis <- "yes"; X_angle <- as.numeric(as.character(X_angle)) }
if ("Y_angle" %in% FFInfo$Info) { dothis <- "yes"; Y_angle <- as.numeric(as.character(Y_angle)) }

if (dothis == "yes") {
  MyAxisX_Setting <- element_text(angle = X_angle, hjust = 0.5, size = XaxisSize, face = "bold", color = "black")
  MyAxisY_Setting <- element_text(angle = Y_angle, hjust = 1, size = YaxisSize, face = "bold", color = "black")

}



