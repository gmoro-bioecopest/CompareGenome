#!/bin/bash

. scripts/blast.sh
. scripts/step_1.sh
. scripts/step_2.sh
. scripts/step_3.sh
. scripts/step_4.sh
. scripts/step_5.sh

show_help() {
  cat << EOF
Usage: $0     [--num-cores/-n <num_cores>] [--reference/-r <reference_file>]
                        [--genomes/-g <list of genomes to compare>]
                        [--output-dir/-o <output_folder>]

Run $__appname__ with the specified options.

Options:
  --num-cores, -n   Number of core to use. Default: $__processor__

  --reference, -r   The full path of the reference genome, in genebank format.
                    You can use your own reference file or alternatively download from public databases.
                    It is best that the reference genome and your genome assemblies belong to the same species.
                    In case this is not possible, you can choose the most closely related species.

  --genomes,   -g   The full path of the genome assemblies to compare.
                    The files must be in fasta format and at least 2 genomes are required.
                    If you have one genome assembly only, you can download the missing genome assembly from public databases.
                    In this case it is best to choose the same species of your own assembly, or a closely related one.

  --output-dir,-o   The full path of the output folder. $__appname__ will save analysis outputs in this folder.

  --help, -h        Show this help message and exit
EOF
  exit 1
}

parse_args() {
  while [ "$1" != "" ]; do
    case $1 in
      --help | -h)
          show_help
          ;;
      --numn-cores | -n)
          PROCESSORS="$2"
          shift
          shift
          ;;
      --reference | -r)
          REFERENCE="$2"
          shift
          shift
          ;;
      --output-dir | -o)
          OUTDIR="$2"
          shift
          shift
          ;;
      --genomes | -g)
          shift
          GENOMES=()
          while [ "$1" != "" ] && [ "${1:0:1}" != "-" ]; do
            GENOMES+=("$1")
            shift
          done
          ;;
      *)
        log "Unknown parameter passed: $1"
        show_help
        ;;
    esac
  done
}


check_reference_file() {

  local f="$1"

  if [ -n "$f" ] && [ -f "$f" ]; then
    activate_conda_env "${__env_compare_genome__}"
    is_genbank=$(python "${__check_genbank__}" "$f" && echo "True" || echo "False")
    if [ "$is_genbank" = "False" ]; then
      log "ERROR: $f is not a valid GebBank file."
      log "Exiting..."
      exit 1
    fi
    deactivate_conda_env
  else
        log "ERROR: $f does not exist or is not a file."
        log "Exiting..."
        exit 1
  fi
}

check_genomes() {
  local genomes=("$@")
  local single_genomes=()
  local max_length=25
  seen_files=()
  
  activate_conda_env "${__env_compare_genome__}"

  for path in "${genomes[@]}"; do
    files=($path)

    for f in "${files[@]}"; do
      if [ -n "$f" ] && [ -f "$f" ]; then
        is_fasta=$(python "${__check_fasta__}" "$f" && echo "True" || echo "False")
        if [ "$is_fasta" = "True" ]; then
          bname=$(basename "$f")
          fname="${bname%.*}"
          lname="${#fname}"
          if [ "$lname" -gt "$max_length" ]; then
            log "ERROR: Too long filename for ${bname}. Please shorten to 25 characters or less."
            log "Exiting..."
            exit 1
          fi

          duplicate=false
          for seen_file in "${seen_files[@]}"; do
            if [ "$seen_file" == "$fname" ]; then
              duplicate=true
              break
            fi
          done

          if [ "$duplicate" = false ]; then
            single_genomes+=("$f")
            seen_files+=("$fname")
          else
            log "ERROR: multiple matches have been found for filename $fname. Please remove duplicates"
            log "Exiting..."
            exit 1
          fi

        else
          log "ERROR: $f is not a valid FASTA file."
          log "Exiting..."
          exit 1
        fi
      else
        log "ERROR: $f does not exist or is not a file."
        log "Exiting..."
        exit 1
      fi
    done
  done

  deactivate_conda_env

  num_genomes="${#single_genomes[@]}"

  if [ "$num_genomes" -lt 2 ]; then
    log "ERROR: Insufficient number of inputs. ${__appname__} requires at least 2 genome assemblies."
    log "Exiting..."
    exit 1
  fi

  GENOMES=("${single_genomes[@]}")
}

setup_project() {

  local job_dir="$1"
  local ref_file="$2"
  local genomes=("${@:3}")

  TMP_DIR="${job_dir}/${__tmp_dir__}"
  check_and_create_directory "$TMP_DIR" "Temporary folder"

  RAW_DIR="${job_dir}/${__raw_dir__}"
  check_and_create_directory "$RAW_DIR" "RawData folder"

  REF_DIR="${job_dir}/${__ref_dir__}"
  check_and_create_directory "$REF_DIR" "Reference folder"

  REF_FILE="${REF_DIR}/${__ref_file__}"

  RES_DIR="${job_dir}/${__out_dir__}"
  check_and_create_directory "$RES_DIR" "Results folder"

  FEATURES_DIR="${job_dir}/${__features_dir__}"
  check_and_create_directory "$FEATURES_DIR" "Features folder"

  BLAST_DIR="${RES_DIR}/${__blast_dir__}"
  check_and_create_directory "$BLAST_DIR" "Blast folder"

  PAIRWISE_DIR="${BLAST_DIR}/${__pairwise_dir__}"
  check_and_create_directory "$PAIRWISE_DIR" "PairwiseBlast folder"

  INPUT_BLAST_DIR="${BLAST_DIR}/${__input_blast_dir__}"
  check_and_create_directory "$INPUT_BLAST_DIR" "Input folder for BLAST"

  OUTPUT_BLAST_DIR="${BLAST_DIR}/${__output_blast_dir__}"
  check_and_create_directory "$OUTPUT_BLAST_DIR" "Output folder for BLAST"

  DB_BLAST_DIR="${BLAST_DIR}/${__db_blast_dir__}"
  check_and_create_directory "$DB_BLAST_DIR" "DB folder for BLAST"

  R_OUT_DIR="${job_dir}/${__Rjob_out__}"
  check_and_create_directory "$R_OUT_DIR" "R output Folder"

 __RJOB_out__="${job_dir}/${__Rjob_out__}/job_r_out.txt"
 __RJOB_err__="${job_dir}/${__Rjob_out__}/job_r_err.txt"


  cp "$ref_file" "$REF_FILE"

  for g in "${genomes[@]}"; do
    cp "$g" "$RAW_DIR/"
    cp "$g" "$DB_BLAST_DIR/"
  done

  FATAL_ERROR_FILE="${job_dir}/${__fatal_error_file__}"
  WARNING_FILE="${job_dir}/${__warning_file__}"

}

run_step_1() {
  stepID="step 1"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file="$1"

  activate_conda_env "$env_file"

  python "${__features_genbank__}" "$REF_FILE" "$FEATURES_DIR"

  log "Merging folders" "$LOG_FILE"
  create_csv_files "$FEATURES_DIR"
  Rscript "${__merge_features__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"

  log "Cleaning temporary files" "$LOG_FILE"
  clean_tmp_files "$FEATURES_DIR"

  log "Creating missing files" "$LOG_FILE"
  create_missing_files "$FEATURES_DIR" "$LOG_FILE"

  log "Removing folders with missing gene sequence" "$LOG_FILE"
  check_and_remove_empty_folders "$FEATURES_DIR" "$LOG_FILE"

  log "Concatenating annotation info" "$LOG_FILE"
  concatenate_annotation_info "$FEATURES_DIR" "$LOG_FILE"

  log "Adding folderID" "$LOG_FILE"
  add_basename_files "$FEATURES_DIR" "$LOG_FILE"

  deactivate_conda_env
}

run_step_2() {
  stepID="step 2"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  local env_file_blast="$2"

  activate_conda_env "$env_file_r"
  log "Preparing files for Blast" "$LOG_FILE"
  prepare_blast_input_files "$FEATURES_DIR" "$INPUT_BLAST_DIR"

  log "Creating and Indexing DB" "$LOG_FILE"
  dbcode "$BLAST_DIR" "$DB_BLAST_DIR"
  clean_db_dir "$BLAST_DIR" "$DB_BLAST_DIR" "$INPUT_BLAST_DIR"
  deactivate_conda_env

  activate_conda_env "$env_file_blast"
  log "Making Blast DB" "$LOG_FILE"
  make_blast "$DB_BLAST_DIR"

  log "Making Blast" "$LOG_FILE"
  run_blast "$INPUT_BLAST_DIR" "$OUTPUT_BLAST_DIR" "$DB_BLAST_DIR" "$__blast_outfmt__" "$PROCESSORS"
  deactivate_conda_env

  clean_folder "${TMP_DIR}"

}

run_step_3() {
  stepID="step 3"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  local env_file_blast="$2"

  activate_conda_env "$env_file_r"
  Rscript "${__step_3__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"

  handle_fatal_error "$FATAL_ERROR_FILE" "$WARNING_FILE" "$LOG_FILE"

  Rscript "${__box_plot_free_code__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"

  log "Running pairwise comparison" "$LOG_FILE"
  Rscript "${__step_3_blast__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  deactivate_conda_env

  activate_conda_env "$env_file_blast"
  blastPairwiseBatch "$PAIRWISE_DIR" "$__blast_outfmt__"
  deactivate_conda_env

}

run_step_4() {
  stepID="step 4"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  activate_conda_env "$env_file_r"
  Rscript "${__step_4__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  log "Adding missing files" "$LOG_FILE"
  add_missing_text "$FEATURES_DIR" "$LOG_FILE"
  deactivate_conda_env
}

run_step_5() {
  stepID="step 5"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  activate_conda_env "$env_file_r"
  Rscript "${__step_5__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  Rscript "${__step_5a__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"

  log "Extracting GO terms from sequences" "$LOG_FILE"
  Rscript "${__go_terms_retrieve__}" "$MAIN_DIR" "$JOB_DIR" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  for myfeat in "${JOB_DIR}/${__features_dir__}/"*; do cd $myfeat;grep -o 'GO:[0-9]\+' All_cds_features.csv >Go_terms.txt;cd -; done >/dev/null 
  process_GO_terms "$FEATURES_DIR" "$LOG_FILE"

  Rscript "${__step_5GO__}" "${MAIN_DIR}" "${JOB_DIR}" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  Rscript "${__step_6__}" "${MAIN_DIR}" "${JOB_DIR}" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  Rscript "${__bar_plot_core_code__}" "${MAIN_DIR}" "${JOB_DIR}" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  deactivate_conda_env
}

run_step_6() {
  stepID="step 6"
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  activate_conda_env "$env_file_r"
  Rscript "${__step_6PCA__}" "${MAIN_DIR}" "${JOB_DIR}" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  deactivate_conda_env
}

run_step_8() {
  stepID="step 8"
  __timestamp_s8__=$(date +"%y%m%d-%H%M%S")
  echo $stepID >>$__RJOB_out__
  echo $stepID >>$__RJOB_err__

  local env_file_r="$1"
  activate_conda_env "$env_file_r"
  Rscript "${__step_8__}" "${MAIN_DIR}" "${JOB_DIR}" "${OUTDIR}" "${__timestamp_s8__}" >>"$__RJOB_out__" 2>>"$__RJOB_err__"
  deactivate_conda_env
  rm -rf "${JOB_DIR}"
}
