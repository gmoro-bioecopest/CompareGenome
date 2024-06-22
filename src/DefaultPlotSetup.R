

MyTitle <- "" #general title
KeyTitle <- "" #title for key heatmaps

MyBarColors <- "orange"

DoZscores <- "no" #options "yes" "no"

TrasposePlot <- "no" #options "yes" "no"

MyDescription <- paste0("test description")

analysisSpecifics <- ""

AlphaPlot <- "no" #options "yes" "no"

MyAngleLabels <- 0 #90 for vertical and 0 for horizontal

Y_label <- ""
X_label <- ""

DotSize <- 5

MyinfLim <- 1.2
MyuppLim <- 1.2


psf <- read.csv(paste0(ScriptsDir, "PlotSize.csv"))
psf <- subset(psf, !Info=="Info")
names(psf) <- psf[1,]

nrowcodes <- c("HeatmapCoreCode.R", "PlotPcaCoreCode.R")
if(mainplotscript%in%nrowcodes){psf <- subset(psf, RowNo==nrow(FF))}else{
  psf <- subset(psf, RowNo==length(unique(FF$X_Axis)))}
if(mainplotscript=="DeseqVolcanoPlotCode.R"){
  psf <- read.csv(paste0(ScriptsDir, "PlotSize.csv"))
  psf <- subset(psf, !Info=="Info")
  names(psf) <- psf[1,]
  
  psf <- subset(psf, RowNo==10)}
MyHeight <- MyWidth <- as.numeric(as.character(psf$AreaSide))


baseSize <- as.numeric(as.character(psf$TextSize))
TitleSize <- baseSize*1.2
CaptionSize <- baseSize*1
XaxisSize <- baseSize*1
YaxisSize <- baseSize*1

MyWidth <- as.numeric(as.character(MyWidth))

MyTitleSetting <- element_text(color = "black", size = TitleSize, face = "bold", hjust = 0)
MySubTitleSetting <- element_text(color = "blue")
MyCaptionSetting <- element_text(color = "black", size = CaptionSize, face = "bold", hjust =0, vjust=0)

MyAxisTitleSetting <- element_text(face="bold", size=22, color="black")
X_angle <- 55 #90 for vertical and 0 for horizontal
Y_angle <- 0 #90 for vertical and 0 for horizontal

if(mainplotscript=="PlotPcaCoreCode.R"){X_angle <- 0}

MyAxisX_Setting <- element_text(angle = X_angle, hjust = 1, size=XaxisSize, face="bold", color="black")
MyAxisY_Setting <- element_text(angle = Y_angle, hjust = 1, size=YaxisSize, face="bold", color="black")
MyAxisTicks_Setting <- element_line("black", linewidth=1)
MyAxisLine_Setting <- element_line("black", linewidth = 1)


errbarNote <- ""#default
errbar <- "se" #choose between se and sd






