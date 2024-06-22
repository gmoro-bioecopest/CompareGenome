#!/bin/bash

# shellcheck disable=SC2034
__appname__=$(<APPNAME)
__version__=$(cat VERSION | head -n 1)
__release__=$(cat VERSION | tail -1)
__description__=$(<DESCRIPTION)
__authors__=$(<AUTHORS)

__timestamp__=$(date +"%y%m%d-%H%M%S")
#__timestamp__="240127-132900" #manual edit for testing

__install_dir__=$(pwd)

__src_dir__="${__install_dir__}/src"
__config_dir__="${__install_dir__}/config"

__Rinstall_out__="R_out_install"
__Rjob_out__="R_out_job"
__tmp_dir__="Temp"
__out_dir__="Outputs"
__blast_dir__="Blast"
__input_blast_dir__="InputFiles"
__output_blast_dir__="OutputFiles"
__db_blast_dir__="Subject_databases"
__pairwise_dir__="PairwiseBlast"
__raw_dir__="RawData"
__ref_dir__="ReferenceFile"
__ref_file__="ReferenceGenome.gbk"
__features_dir__="features"

__env_compare_genome__="${__config_dir__}/compare_genome.yml"
__env_blast__="${__config_dir__}/blast.yml"

__check_r__="${__src_dir__}/CheckRpackage.R"
__Rout__="${__install_dir__}/${__Rinstall_out__}/installation_r_out.txt"
__Rerr__="${__install_dir__}/${__Rinstall_out__}/installation_r_err.txt"
__check_install__="${__install_dir__}/InstallationCheck.txt"
__check_fasta__="${__src_dir__}/check_fasta.py"
__check_genbank__="${__src_dir__}/check_genbank.py"
__features_genbank__="${__src_dir__}/parse_genbank_features.py"
__merge_features__="${__src_dir__}/MergeFeatures.R"
__step_2__="${__src_dir__}/Step2.R"
__step_3__="${__src_dir__}/Step3.R"
__step_3_blast__="${__src_dir__}/Step3_pairBlast.R"
__step_4__="${__src_dir__}/Step4_summary.R"
__step_5__="${__src_dir__}/Step5.R"
__step_5a__="${__src_dir__}/Step5a.R"
__step_5GO__="${__src_dir__}/Step5GO.R"
__step_6__="${__src_dir__}/Step6.R"
__step_6PCA__="${__src_dir__}/Step6PCA.R"
__step_8__="${__src_dir__}/Step8.R"

__go_terms_retrieve__="${__src_dir__}/GoTermsRetrieve.R"
__box_plot_free_code__="${__src_dir__}/BoxPlots/Step3ViolinPlot/BoxPlotFreeCode.R"
__bar_plot_core_code__="${__src_dir__}/BarPlots/GO_enrichment/BarPlotCoreCode.R"


__blast_outfmt__="7 sseqid qseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen qseq sseq "

__fatal_error_file__="FatalError.txt"
__warnings_file__="Warnings.txt"

__log_msg__=""

__compare_genome__="CompGen.sh"

if command -v nproc &> /dev/null; then
    __processor__=$(($(nproc) / 2))
elif command -v sysctl &> /dev/null; then
    __processor__=$(sysctl -n hw.ncpu)
    __processor__=$((__processor__ / 2))
else
    __processor__=1
fi

