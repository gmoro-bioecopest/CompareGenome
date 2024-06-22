args <- commandArgs(trailingOnly = TRUE)


ScriptsDir <- paste0(args[1], "/src/")
MyDir <- paste0(args[1], "/")

system(paste0("echo 'InstalledPackages' >", MyDir, "InstallationCheckList.txt"))

InstPackGroup <- c("BiocManager", "agricolae", "sp", "RcppArmadillo", "ade4", "seqinr", "gplots", "Rmisc", "phangorn", "ggrepel", "cowplot", "openssl", "factoextra")
BiocManGroup <- c("ggtree","GO.db")
Allgroups <- c(InstPackGroup, BiocManGroup)

for (ip in Allgroups) {
  availtext <- paste0("is_", ip, "_available<- require('", ip, "')")
  availCode <- eval(parse(text = availtext))
  mypackage <- ip

  if (availCode == "FALSE") { insttext <- paste0("install.packages('", ip, "',repos = 'http://cran.us.r-project.org')")
    instCode <- eval(parse(text = insttext)) }

  availCode <- eval(parse(text = availtext))
  if (availCode == "FALSE") {
    insttext <- paste0("BiocManager::install('", ip, "')")
    instCode <- eval(parse(text = insttext))
  }

}
for (ip in Allgroups) {
  availtext <- paste0("is_", ip, "_available<- require('", ip, "')")
  availCode <- eval(parse(text = availtext))
  mypackage <- ip
  if (availCode == "TRUE") { system(paste0("echo '", mypackage, "' >>", MyDir, "InstallationCheckList.txt")) }
}


CheckList <- read.csv(paste0(MyDir, "InstallationCheckList.txt"))
Ag <- data.frame(A = Allgroups)
Ag$Ch <- ifelse(Ag$A %in% CheckList$InstalledPackages, "y", "missing")
missing <- subset(Ag, Ch == "missing")

if (nrow(missing) > 0) {
  system(paste0("echo 'WARNING: CompàreGenome failed in installing the following R packages:\n' >>", MyDir, "InstallationCheck.txt"))
  system(paste0("echo '", unique(missing$A), "\n' >>", MyDir, "IntallationCheck.txt"))
  system(paste0("echo 'This may result in incomplete analysis. Please try to install manually within the conda environment CompareGenome' >>", MyDir, "InstallationCheck.txt"))
}



