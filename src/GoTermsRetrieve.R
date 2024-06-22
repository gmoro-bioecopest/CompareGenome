args <- commandArgs(trailingOnly = TRUE)

ScriptsDir <- paste0(args[1], "/src/")
JobDir <- paste0(args[2], "/")

system(paste0("cd ", JobDir, "features;find $PWD -type f -name 'All_cds_features.csv' >", JobDir, "SequenceList.txt"))


