args <- commandArgs(trailingOnly = TRUE)


library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(gplots)

ScriptsDir <- paste0(args[1], "/src/")
TempDir <- paste0(args[2], "/Temp/")
MyDir <- paste0(args[2], "/Outputs/")
RawDir <- paste0(args[2], "/RawData/")
JobDir <- paste0(args[2], "/")

mypattern <- "Blast"
analysisdir <- paste0(MyDir, mypattern, "/")

Inputdir <- paste0(analysisdir, "InputFiles/")
Outputdir <- paste0(analysisdir, "OutputFiles/")
Dbdir <- paste0(analysisdir, "/Subject_databases/")

plotdir <- paste0(analysisdir, "Heatmaps/")

Altab <- read.csv(paste0(plotdir, "AlignmentTable.csv"))
names(Altab)
rownames(Altab) <- Altab$query_id
Altab$X <- NULL
Altab$query_id <- NULL
Altab$st_dev <- NULL
Altab$average <- NULL
Altab$rows <- NULL
Altab$SimilarityRank <- NULL
Altab$protein_id <- NULL
Altab$ProductID <- NULL
Altab$group <- NULL

res <- data.frame(cor(Altab))
write.csv(res, paste0(plotdir, "CorrelationTable.csv"))



hcolManual <- colorRampPalette(c("yellow1", "yellow2", "yellow3", "black", "blue3", "blue2", "blue1"))





DoZscores <- "no"
if (DoZscores == "yes") { Myscale <- "row"
  col_breaks <- NULL }else { Myscale <- "none"
  col_breaks <- c(seq(-1, 0, length = 100),
                  seq(0.001, 1, length = 100))
}


analysisSpecifics <- ""
if (DoZscores == "yes") { analysisSpecifics <- paste0(bname, "_Zscores") }


PlotLabelName <- paste0(plotdir, "CorrelationMatrix.pdf")
system(paste0(" echo '", PlotLabelName, "' >>", JobDir, "OutputList.csv"))


d <- res

psf <- read.csv(paste0(ScriptsDir, "PlotSize.csv"))
psf <- subset(psf, !Info == "Info")
names(psf) <- psf[1,]
psf <- subset(psf, RowNo == ncol(d))
MyWidth <- as.numeric(as.character(psf$AreaSide))
MyHeight <- MyWidth

HeatCol <- "default" #options "default","custom"
hcoldefault <- colorRampPalette(brewer.pal(9, "YlOrRd"))(99)
hcolManual <- colorRampPalette(c("yellow1", "yellow2", "yellow3", "black", "blue3", "blue2", "blue1"))

if (HeatCol == "default") { hcol <- hcoldefault }
if (HeatCol == "custom") { hcol <- hcolManual }


dc <- d

pdf(PlotLabelName, height = MyHeight, width = MyWidth)
out <- heatmap.2(as.matrix(dc),

                 lwid = c(1, 4),
                 lhei = c((MyWidth * 0.1), (MyWidth * 0.5)),
                 cexRow = 2,
                 cexCol = 2,
                 Colv = T,
                 Rowv = T,
                 srtCol = 45,
                 dendrogram = "both", #options "both","row","column","none"
                 col = hcol, #options hmcol=YlGnBu hcol=customized(see above)
                 scale = Myscale,
                 margin = c(40, 40),
                 trace = "none",
                 key = TRUE,
                 key.par = list(cex = 1.1),
                 key.title = "Correlation"
)

dev.off()

MyScript <- "Step5a.R"
endtext <- paste0(Sys.time(), ": ", MyScript, " done")
print(endtext)
  


