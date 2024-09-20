#!/bin/bash

. config/config.sh
. scripts/common.sh
. scripts/__compare_genome__.sh

MAIN_DIR="${__install_dir__}"

log "${__appname__} - V.${__version__} [${__release__}] by ${__authors__}"
log "${__description__}"

# Parsing & Checking ARGS
parse_args "$@"

check_mandatory_argument "$REFERENCE" "--reference | -r" "Please provide a valid reference file in GenBank format (.gbk)."
check_mandatory_argument "$GENOMES" "--genomes | -g" "Please provide 2 or more valid genome assemblies in fasta format (.fa or .fasta) to compare."
check_mandatory_argument "$OUTDIR" "--output-dir | -o" "Please provide a valid path for output folder."
check_processors

check_reference_file "$REFERENCE"
check_genomes "${GENOMES[@]}"
check_and_create_directory "$OUTDIR" "Output folder"

OUTDIR=$(realpath ${OUTDIR})


# Initialize LOG FILE
write_log  "$__log_msg__" "$LOG_FILE"
__log_msg__=""

log "Starting analysis"

#### Setup
log "Starting preliminary setup"
LOG_FILE="${OUTDIR}/${__appname__}.${__timestamp__}.log"
JOB_DIR="${OUTDIR}/Job_${__timestamp__}"
R_OUT_DIR="${OUTDIR}/Job_${__timestamp__}/${__Rjob_out__}"
OUT_FOLD="${OUTDIR}/${__appname__}"
check_and_create_directory "$R_OUT_DIR" "R output Folder"

setup_project "$JOB_DIR" "$REFERENCE" "${GENOMES[@]}"
dump_log "$LOG_FILE"

### STEP-1: retrieve features from the reference genome
log "Starting step 1 of 6" "$LOG_FILE"
log "Retrieve features from the reference genome" "$LOG_FILE"
run_step_1 "$__env_compare_genome__"
log "Step 1 of 6 DONE" "$LOG_FILE"

### STEP-2:
log "Starting step 2 of 6" "$LOG_FILE"
run_step_2 "$__env_compare_genome__" "$__env_blast__"
log "Step 2 of 6 DONE" "$LOG_FILE"

### STEP-3:
log "Starting step 3 of 6" "$LOG_FILE"
run_step_3 "$__env_compare_genome__"  "$__env_blast__"
log "Step 3 of 6 DONE" "$LOG_FILE"

### STEP-4:
log "Starting step 4 of 6" "$LOG_FILE"
run_step_4 "$__env_compare_genome__"
log "Step 4 of 6 DONE" "$LOG_FILE"

### STEP-5:
log "Starting step 5 of 6" "$LOG_FILE"
run_step_5 "$__env_compare_genome__"
log "Step 5 of 6 DONE" "$LOG_FILE"

### STEP-6:
log "Starting step 6 of 6" "$LOG_FILE"
run_step_6 "$__env_compare_genome__"
log "Step 6 of 6 DONE" "$LOG_FILE"

### FINAL STEP: saving outputs:
log "Collecting Outputs" "$LOG_FILE"
run_step_8 "$__env_compare_genome__"
log "Collecting outputs DONE.

Analysis completed. Please find results and the log file in the following directory: 
${OUTDIR}. 

Thanks for using CompàreGenome" "$LOG_FILE"