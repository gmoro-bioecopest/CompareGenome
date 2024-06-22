
MyScript <- "BoxPlotCoreCode.R"

starttext <- paste0(Sys.time(), ": starting ", MyScript)
print(starttext)


datafile <- EditDf_df #skip this if doing optimization plot
FF <- read.csv(datafile) #file

system(paste0(" echo '", starttext, "\n",
              "'>>", cfol, "History.txt"))

FF <- dplyr::select(FF, Treatment, ObservationValue, PlotOrder)
names(FF) <- c("X_Axis", "Y_Axis", "XaxisOrder")
FF$Label <- ""


source(paste0(ScriptsDir, "ggplotSetting.R"))

source(paste0(ScriptsDir, "FitPlotDescription.R"))

names(pdfFonts())
quartzFonts()
deffont <- "Times"
defface <- "plain"


defsize <- 20
MyTitleSetting <- element_text(color = "black", size = defsize, face = defface, hjust = 0.5)
MySubTitleSetting <- element_text(color = "black", size = defsize * 0.6, face = defface, hjust = 0, vjust = 0)
MyCaptionSetting <- element_text(color = "black", size = defsize, family = deffont, face = defface, hjust = 0, vjust = 0)

MyAxisTitleSetting <- element_text(family = deffont, face = defface, size = defsize, color = "black")
MyAxisX_Setting <- element_text(angle = 45, hjust = 1, size = defsize, color = "black", family = deffont, face = defface)
MyAxisY_Setting <- element_text(angle = 0, hjust = 1, size = defsize, color = "black", family = deffont, face = defface)

MyAxisTicks_Setting <- element_line("black", linewidth = 0.5)
MyAxisLine_Setting <- element_line("black", linewidth = 0.5)

MyHeight <- 10
MyWidth <- 10 + (length(unique(FF$X_Axis)) * 0.25)

minY <- 0 #default
if (min(FF$Y_Axis) > 0) { minY <- 0 }
if (min(FF$Y_Axis) < 0) { minY <- min(FF$Y_Axis) < 0 }
maxY <- max(FF$TopValue) + (max(FF$TopValue) * 0.2)

quartList <- c(100)
for (sumsub in unique(FF$X_Axis)) {

  FFsub <- subset(FF, X_Axis == sumsub)
  sumFF <- data.frame(summary(FFsub))
  sumFF$sel <- ifelse(grepl("1st Qu.", sumFF$Freq) == TRUE, "y", "")
  sumFF <- subset(sumFF, sel == "y")

  sumFF$sel <- ifelse(grepl("Y_Axis", sumFF$Var2) == TRUE, "y", "")
  sumFF <- subset(sumFF, sel == "y")
  quart <- sumFF$Freq
  quart <- gsub("1st Qu.:", "", quart)
  quart <- as.numeric(as.character(quart))
  quartList <- c(quartList, quart)
}
FF$Y_orig <- FF$Y_Axis
FF$Y_Axis <- ifelse(FF$Y_Axis < (min(quartList) * 0.9), (min(quartList) * 0.9), FF$Y_Axis)

PlotOpt1 <- ggplot(FF, aes(x = reorder(X_Axis, XaxisOrder), Y_Axis, color = X_Axis)) +
  stat_boxplot(aes(x = X_Axis, y = Y_Axis), geom = 'errorbar', width = 0.5, color = "black") +
  geom_boxplot(color = "black", size = 0.5, fill = "white", width = 0.8, outlier.size = 0.05, outlier.color = "white") +

  theme(
    plot.title = MyTitleSetting,
    plot.subtitle = MySubTitleSetting,
    plot.caption = MyCaptionSetting) +
  scale_fill_manual(values = MyBarColors) +
 theme(
    axis.title = MyAxisTitleSetting,
    axis.text.x = MyAxisX_Setting,
    axis.text.y = MyAxisY_Setting,
    axis.ticks = MyAxisTicks_Setting,
    axis.line = MyAxisLine_Setting) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"),
        plot.background = element_rect(color = "white", fill = "white")) +

  theme(aspect.ratio = 0.7) + #it will increase/decrease plot width

  theme(legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.position = "none",
        legend.justification = c(0.5, 1),
        legend.text = element_text(margin = margin(t = 0), size = 12),
        legend.spacing.x = unit(0.3, 'cm')) +
  theme(legend.title = element_blank()) +
  ylab("Alignment Score (%)") +
  xlab("") +
  expand_limits(y = c((min(quartList) * 0.9), maxY))

FigNo <- ""
MyCaption <- paste0("Overview of the alignment to the reference genome\nn=", length(unique(All_TopBitScore$query_id)), " nucleotide sequences\n")


analysisSpecifics <- bname
PlotLabelName <- paste0(cfol, "WholeGenomeComparison.pdf")

pdf(PlotLabelName, height = MyHeight, width = MyWidth)
MyPlot <- PlotOpt1 +

  labs(title = MyTitle,
       subtitle = "",
       caption = MyCaption)

if (TrasposePlot == "yes") { MyPlot <- PlotOpt1 +
  scale_fill_brewer(palette = "Blues") +
  coord_flip()
  labs(title = MyTitle,
       subtitle = "",
       caption = MyCaption) }

print(MyPlot, ncol = 1)
dev.off()

FF2 <- subset(FF, !Y_orig == 0)

FF2$groups <- ifelse(FF2$Y_orig >= 95, "95-100%",
                     ifelse(FF2$Y_orig >= 85, "85-95%",
                           ifelse(FF2$Y_orig >= 70, "70-85%", "<70%"
                           )))


freq <- data.frame(table(FF2$X_Axis, FF2$groups))
names(freq) <- c("strain", "group", "value")
ggplot(freq, aes(fill = group, y = value, x = strain)) +
  geom_bar(position = "dodge", stat = "identity")

cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#0072B2", "#D55E00", "#009E73",
          "#CC79A7", "#F0E442")

PlotOpt2 <- ggplot(freq, aes(fill = group, y = value, x = strain)) +
  geom_bar(position = "stack", stat = "identity", width = 0.5, color = "black") +

  theme(
    plot.title = MyTitleSetting,
    plot.subtitle = MySubTitleSetting,
    plot.caption = MyCaptionSetting) +

  scale_fill_manual("Similarity class", values = cbp1) +

 theme(
    axis.title = MyAxisTitleSetting,
    axis.text.x = MyAxisX_Setting,
    axis.text.y = MyAxisY_Setting,
    axis.ticks = MyAxisTicks_Setting,
    axis.line = MyAxisLine_Setting) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"),
        plot.background = element_rect(color = "white", fill = "white")) +

  theme(aspect.ratio = 0.7) + #it will increase/decrease plot width

  theme(legend.direction = "horizontal",

        legend.box = "horizontal",
        legend.position = "top",
        legend.justification = c(0.5, 1),
        legend.text = element_text(margin = margin(t = 0), size = defsize * 0.8, family = deffont, face = defface),
        legend.key.size = unit(0.8, "cm"),
        legend.spacing.x = unit(0.3, 'cm')) +
  theme(legend.title = element_text(color = "black", size = defsize, family = deffont, face = defface)) +
  ylab("Number Of Aligned Sequences") +
  xlab("") +
  expand_limits(y = c(0, length(unique(All_TopBitScore$query_id))))

FigNo <- ""
MyCaption <- "\n"

PlotLabelName2 <- paste0(cfol, "StackedBarPlot.pdf")

pdf(PlotLabelName2, height = MyHeight, width = MyWidth)
MyPlot2 <- PlotOpt2 +
  labs(title = MyTitle,
       subtitle = "",
       caption = MyCaption)


print(MyPlot2, ncol = 1)
dev.off()

PlotOpt1 <- ggplot(FF, aes(x = reorder(X_Axis, XaxisOrder), Y_Axis, color = X_Axis)) +
  stat_boxplot(aes(x = X_Axis, y = Y_Axis), geom = 'errorbar', width = 0.5, color = "black") +
  geom_boxplot(color = "black", size = 0.5, fill = "white", width = 0.8, outlier.size = 0.05, outlier.color = "white") +

  theme(
    plot.title = MyTitleSetting,
    plot.subtitle = MySubTitleSetting,
    plot.caption = MyCaptionSetting) +
  scale_fill_manual(values = MyBarColors) +

theme(
    axis.title = MyAxisTitleSetting,
    axis.text.x = MyAxisX_Setting,
    axis.text.y = MyAxisY_Setting,
    axis.ticks = MyAxisTicks_Setting,
    axis.line = MyAxisLine_Setting) +
  theme(panel.grid = element_blank(), panel.background = element_rect(fill = "white"),
        plot.background = element_rect(color = "white", fill = "white")) +

  theme(aspect.ratio = 0.7) + #it will increase/decrease plot width

  theme(legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.position = "none",
        legend.justification = c(0.5, 1),
        legend.text = element_text(margin = margin(t = 0), size = 12),
        legend.spacing.x = unit(0.3, 'cm')) +
  theme(legend.title = element_blank()) +
  ylab("Alignment Score (%)") +
  xlab("") +
  expand_limits(y = c((min(quartList) * 0.9), maxY))

FigNo <- ""
MyCaption <- "\n"


analysisSpecifics <- bname
PlotLabelName <- paste0(cfol, "WholeGenomeComparison.pdf")

pdf(PlotLabelName, height = MyHeight, width = MyWidth)
MyPlot <- PlotOpt1 +

  labs(title = MyTitle,
       subtitle = "",
       caption = MyCaption)

if (TrasposePlot == "yes") { MyPlot <- PlotOpt1 +
  scale_fill_brewer(palette = "Blues") +
  coord_flip()
  labs(title = MyTitle,
       subtitle = "",
       caption = MyCaption) }

print(MyPlot, ncol = 1)
dev.off()

MyPlot3 <- cowplot::plot_grid(MyPlot, MyPlot2,
                              labels = c("A", "B"),
                              label_size = defsize * 1.3,
                              label_fontfamily = deffont,
                              label_fontface = defface,
                              ncol = 2, nrow = 1)

PlotLabelName3 <- paste0(cfol, "WholeGenomeComparison2.pdf")
pdf(PlotLabelName3, height = MyHeight, width = MyWidth * 2)

print(MyPlot3, ncol = 1)
dev.off()


system(paste0(" echo '", PlotLabelName, "' >>", JobDir, "OutputList.csv"))
system(paste0(" echo '", PlotLabelName2, "' >>", JobDir, "OutputList.csv"))
system(paste0(" echo '", PlotLabelName3, "' >>", JobDir, "OutputList.csv"))

endtext <- paste0(Sys.time(), ": ", MyScript, " done")
print(endtext)

system(paste0(" echo '", endtext, "\n",
              "'>>", cfol, "History.txt"))
