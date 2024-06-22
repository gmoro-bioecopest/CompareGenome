#!/bin/bash

handle_fatal_error() {
  local fatal_error_file="$1"
  local warnings_file="$2"
  local log_file="$3"

  if [ -f "$fatal_error_file" ]; then
    local folder_path=$(dirname "$fatal_error_file")

    log_file_content "$warnings_file" "$log_file"
    log_file_content "$fatal_error_file" "$log_file"

    purge_folder "$folder_path"

    log "Exiting... " "$log_file"
    exit 1
  fi
}



blastPairwiseBatch() {
  local base_dir="$1"
  local outfmt="$2"

  find "$base_dir" -mindepth 1 -type d -name "sequence_*" | while read -r folder_path; do

    blastPairwise "${folder_path}" "${outfmt}"

  done
}




