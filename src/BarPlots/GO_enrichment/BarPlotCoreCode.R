args <- commandArgs(trailingOnly = TRUE)

library(ggplot2)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

mypattern <- "GO_Enrichment"
analysisdir <- paste0(MyDir, mypattern, "/")

goc <- read.table(paste0(MyDir, "DoGO.txt"))

if (goc$V1 == "yes") {
  system(paste0("cd ", analysisdir, "; find $PWD -type f -name 'PositivelyEnrichedOnly.csv' >", analysisdir, "EnrichedList.txt"))

  scorel <- read.table(paste0(analysisdir, "EnrichedList.txt"))
  FullAn <- read.csv(paste0(MyDir, "GoFullAnnotation.csv"))
  FullAn <- dplyr::select(FullAn, ONTOLOGY, TERM)
  names(FullAn) <- c("GoGroup", "Factor")

  for (score in scorel$V1) {
scorefile <- read.csv(score)
    if (nrow(scorefile) > 0) {
      scorefile$X <- NULL
      scorefile$GoGroup <- NULL
      scorefile <- merge(scorefile, FullAn, by = "Factor", all = F)
      scorefname <- gsub(".*/", "", score)
      scorefold <- gsub(scorefname, "", score)
      FFInfo <- read.csv(paste0(scorefold, "FFInfo.csv"))
      cfol <- scorefold
      SumData_df <- paste0(scorefold, "PositivelyEnrichedOnly.csv")

      write.csv(scorefile, paste0(scorefold, "PositivelyEnrichedOnly.csv"))

      MyScript <- "BarPlotCoreCode.R"

      starttext <- paste0(Sys.time(), ": starting ", MyScript)
      print(starttext)

    datafile <- SumData_df 
      FF <- read.csv(datafile) 
      FF$Factor <- ifelse(nchar(FF$Factor) > 40, paste0(substr(FF$Factor, 1, 40), "..."), FF$Factor)

      system(paste0(" echo '", starttext, "\n",
                    "'>>", cfol, "History.txt"))


      source(paste0(ScriptsDir, "ggplotSetting.R"))

      source(paste0(ScriptsDir, "FitPlotDescription.R"))

      TrasposePlot <- "no"

      FF$Count <- FF$ObservedValue

      FF$Fisher_pvalue <- FF$P_value
      FF <- FF[order(FF$ObservedValue, decreasing = T),]
      toptitle <- ""
      if (nrow(FF) > 20) {
        FF$nr <- 1:nrow(FF)
        FF$nr2 <- ifelse(FF$nr > 20, "rm", "")
        FF <- subset(FF, !nr2 == "rm")
      }

      names(pdfFonts())
      quartzFonts()
      deffont <- "Times"
      defface <- "plain"


      defsize <- 20
      MyTitleSetting <- element_text(color = "black", size = defsize, face = defface, hjust = 0.5)
      MySubTitleSetting <- element_text(color = "black", size = defsize * 0.6, face = defface, hjust = 0, vjust = 0)
      MyCaptionSetting <- element_text(color = "black", size = defsize * 0.8, face = defface, hjust = 0, vjust = 0)

      MyAxisTitleSetting <- element_text(family = deffont, face = defface, size = defsize, color = "black")
      MyAxisX_Setting <- element_text(angle = 0, hjust = 0.5, size = defsize, color = "black", family = deffont, face = defface)
      MyAxisY_Setting <- element_text(angle = 0, hjust = 1, size = defsize, color = "black", family = deffont, face = defface)

      MyAxisTicks_Setting <- element_line("black", linewidth = 0.5)
      MyAxisLine_Setting <- element_line("black", linewidth = 0.5)

      MyHeight <- 10
      MyWidth <- 10 + (nrow(FF) * 0.2)

      minY <- 0 #default
      if (min(FF$Y_Axis) > 0) { minY <- 0 }
      if (min(FF$Y_Axis) < 0) { minY <- min(FF$Y_Axis) < 0 }
      maxY <- max(FF$TopValue) + (max(FF$TopValue) * 0.2)

      FF <- FF[order(FF$GoGroup, -FF$ObservedValue),]
      newFF <- FF[1,]
      newFF$Factor <- "rm"
      subMF <- subset(FF, GoGroup == "MF")
      subBP <- subset(FF, GoGroup == "BP")
      subCC <- subset(FF, GoGroup == "CC")
      if (nrow(subMF) > 0) { newFF <- rbind(newFF, subMF) }
      if (nrow(subBP) > 0) { newFF <- rbind(newFF, subBP) }
      if (nrow(subCC) > 0) { newFF <- rbind(newFF, subCC) }
      newFF <- subset(newFF, !Factor == "rm")
      FF <- newFF
      FF$myorder <- 1:nrow(FF)
      FF$GoGroup <- factor(FF$GoGroup, levels = c('MF', 'BP', 'CC'))

      MyBarColors <- "dodgerblue"
      PlotOpt1 <- ggplot(FF, aes(x = ObservedValue, y = reorder(Factor, -myorder))) +

        theme(
          plot.title = MyTitleSetting,
          plot.subtitle = MySubTitleSetting,
          plot.caption = MyCaptionSetting) +

        geom_bar(stat = "identity", position = "dodge", width = 0.5, color = "black", size = 0.5, fill = MyBarColors) + #details of border and filling


  theme(
          axis.title = MyAxisTitleSetting,
          axis.text.x = MyAxisX_Setting,
          axis.text.y = MyAxisY_Setting,
          axis.ticks = MyAxisTicks_Setting,
          axis.line = MyAxisLine_Setting) +
        theme(
          panel.grid = element_line(color = "lightgrey", linewidth = 0.2),
          panel.background = element_rect(fill = "white"),
          plot.background = element_rect(color = "white", fill = "white")) +

        theme(aspect.ratio = 3.1) + 
        theme(legend.direction = "vertical",
              legend.box = "vertical",
              legend.position = "right",
              legend.justification = c(0.5, 1),
              legend.text = element_text(margin = margin(t = 5), size = YaxisSize),
              legend.spacing.x = unit(0.3, 'cm'),
              legend.title = element_text(size = YaxisSize)) +
        ylab(paste0("GO Terms\n")) +
        xlab(paste0("\nGene Count")) +
        scale_size_area()

      FigNo <- "Fig"
      bname <- ""
      bname <- scorefold
      bname <- gsub(".*GO_Enrichment/", "", bname)
      bname <- gsub("/", "_GO_enrichment", bname)
      bname


      analysisSpecifics <- bname
      PlotLabelName <- paste0(cfol, analysisSpecifics, ".pdf")
      system(paste0(" echo '", PlotLabelName, "' >>", JobDir, "OutputList.csv"))

      length(dev.list())
      if (length(dev.list()) > 0) { dev.off() }

      MyWidth
      if (TrasposePlot == "yes") {
        MyPlot <- PlotOpt1 +
          coord_flip() +
          MyGeomText +
          labs(title = toptitle,
               subtitle = "")

      }else {
        MyPlot <- PlotOpt1 +
          facet_grid(. ~ GoGroup) +

          theme(strip.text.x = element_text(size = YaxisSize, color = "black",
                                            face = "bold")) +

          labs(title = toptitle,
               subtitle = "",
               caption = "\nMF= molecular function\nBP= biological process\nCC= cellular component\n")


      }
      ggsave(
        PlotLabelName,
        plot = MyPlot,

        width = MyWidth,
        height = MyHeight

      )



    }
  }
  endtext <- paste0(Sys.time(), ": ", MyScript, " done")
  print(endtext)


  system(paste0(" echo '", endtext, "\n",
                "'>>", cfol, "History.txt"))

}
