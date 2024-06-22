

MyScript <- "PlotPcaCoreCode2.R"

starttext <- paste0(Sys.time(), ": starting ", MyScript)
print(starttext)

activateOptimization <- "no" #NEVER MODIFY. it will be changed later if necessary
library(ggplot2)
library(phangorn)








if (activateOptimization == "yes") {
  datafile <- paste0(cfol, "EditDf_data.RData")
  FF <- load(datafile)


  Anfold2 <- gsub("/Users/gabriele", "~", Anfold)
  cfolP <- gsub(Anfold2, "", cfol)
  cfolP <- gsub("/", "", cfolP)

  ListSheets <- data.frame(V1 = cfolP)
}

if (activateOptimization == "no") {
  system(paste0("cd ", Anfold, ";ls >list.txt"))
  ListSheets <- read.table(paste0(Anfold, "list.txt"))
  ListSheets$V2 <- ifelse(grepl("Setting", ListSheets$V1), "y", "n")
  ListSheets <- subset(ListSheets, V2 == "y")
  for (i in ListSheets$V1) { if (length(list.files(path = paste0(editfol, i), pattern = "*PcaPlot.pdf")) > 0) { ListSheets <- subset(ListSheets, !V1 == i) } }
}

system(paste0(" echo '", starttext, "\n",
              "'>>", Anfold, "History.txt"))

for (i in ListSheets$V1) {

  cfol <- paste0(Anfold, i, "/") #output directory
  datafile <- paste0(Anfold, i, "/EditDf_data.RData")
  load(datafile) #file
  FF <- y



  source(paste0(ScriptsDir, "ggplotSetting.R"))

  source(paste0(ScriptsDir, "FitPlotDescription.R"))

  psf <- read.csv(paste0(ScriptsDir, "PlotSize.csv"))
  psf <- subset(psf, !Info == "Info")
  names(psf) <- psf[1,]
  psf <- subset(psf, RowNo == nrow(data))
  MyWidth <- MyHeight <- as.numeric(as.character(psf$AreaSide))

  names(pdfFonts())
  quartzFonts()
  deffont <- "Times"
  defface <- "plain"


  defsize <- 20

  MyTitleSetting <- element_text(color = "black", size = defsize, face = defface, hjust = 0.5)
  MySubTitleSetting <- element_text(color = "black", size = defsize * 0.6, face = defface, hjust = 0, vjust = 0)
  MyCaptionSetting <- element_text(color = "black", size = defsize * 0.7, face = defface, hjust = 0, vjust = 0)

  MyAxisTitleSetting <- element_text(family = deffont, face = defface, size = defsize, color = "black")
  MyAxisX_Setting <- element_text(angle = 0, hjust = 0.5, size = defsize, color = "black", family = deffont, face = defface)
  MyAxisY_Setting <- element_text(angle = 0, hjust = 1, size = defsize, color = "black", family = deffont, face = defface)

  MyAxisTicks_Setting <- element_line("black", linewidth = 0.5)
  MyAxisLine_Setting <- element_line("black", linewidth = 0.5)

  MyHeight <- 10
  MyWidth <- 10


  DotSize <- 5

  rotation <- data.frame(data$rotation)
  rotation <- rotation[order(rotation$PC2, decreasing = T),]
  rotation$row <- 1:nrow(rotation)
  rotation$name <- rownames(rotation)

  ip <- "factoextra"
  availtext <- paste0("is_", ip, "_available<- require('", ip, "')")
  availCode <- eval(parse(text = availtext))

  if (availCode == "TRUE") { percentVar <- data.frame(factoextra::get_eigenvalue(data))
    names(percentVar) <- c("eigenvalue", "variance_percent", "cumulative_variance_percent")
    myxlab <- paste0("\nPC1: ", round(percentVar$variance_percent[1], 1), "% variance")
    myylab <- paste0("\nPC2: ", round(percentVar$variance_percent[2], 1), "% variance")
  }else { myxlab <- "\nPC1"; myylab <- "\nPC2" }


  PlotOpt1 <- ggplot(rotation, aes(x = PC1, y = PC2, color = name)) +
    geom_point(size = DotSize) +
    ggrepel::geom_label_repel(aes(label = paste0(" ", name), size = defsize, hjust = 1, vjust = 1)) +

    theme(
      plot.title = MyTitleSetting,
      plot.subtitle = MySubTitleSetting,
      plot.caption = MyCaptionSetting) +



    theme(
      axis.title = MyAxisTitleSetting,
      axis.text.x = MyAxisX_Setting,
      axis.text.y = MyAxisY_Setting,
      axis.ticks = MyAxisTicks_Setting,
      axis.line = MyAxisLine_Setting) +
    theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"),
          plot.background = element_rect(color = "white", fill = "white")) +

    theme(aspect.ratio = 1) + #it will increase/decrease plot width

    theme(legend.direction = "vertical",
          legend.box = "vertical",
          legend.position = "none",
          legend.justification = c(0.5, 1),
          legend.text = element_text(margin = margin(t = 0), size = 12),
          legend.spacing.x = unit(0.3, 'cm')) +
    theme(legend.title = element_blank()) +
    ylab(myylab) +
    xlab(myxlab) +
    coord_fixed()



  analysisSpecifics <- bname

  if (activateOptimization == "no") {
    FigNo <- "FigPCA_"
    PlotLabelName <- paste0(Anfold, i, "/", FigNo, analysisSpecifics, "DotPlot.pdf")
  }

  if (activateOptimization == "yes") {
    PlotLabelName <- paste0(cfol, analysisSpecifics)

  }


  pdf(PlotLabelName, height = MyHeight, width = MyWidth)

  MyPlot <- PlotOpt1 +
    labs(title = "",
         subtitle = "",
         caption = "")
  print(MyPlot, ncol = 1)
  dev.off()


  d <- as.matrix(y)
  sampleTree <- hclust(dist(t(d)), method = "average")


  analysisSpecifics <- bname

  if (activateOptimization == "no") {

    FigNo <- "FigCluster_"
    PlotLabelName <- paste0(Anfold, i, "/", FigNo, analysisSpecifics, "Dendrogram.pdf")
  }

  if (activateOptimization == "yes") {
    PlotLabelName <- paste0(cfol, analysisSpecifics)

  }

  pdf(PlotLabelName, height = MyHeight, width = MyWidth)
  par(oma = c(1, 5, 1, 5), cex = 1)
  plot(as.phylo(sampleTree)
    , edge.width = 3
    , type = "p" # options: "p" classic,"f" circular, ,"r", radial,c" cladogram,"u" unrooted,
    , tip.color = "black" #color labels
    , use.edge.length = F #use TRUE to set proportional branch length
    , label.offset = 0.2
    , cex = 2
  )
  dev.off()


}

endtext <- paste0(Sys.time(), ": ", MyScript, " done")
print(endtext)


system(paste0(" echo '", endtext, "\n",
              "'>>", MyDir, "AnalysisHistory.txt"))
