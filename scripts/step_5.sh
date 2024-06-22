#!/bin/bash

process_GO_terms() {
    local features_dir="$1"
    local log_file="$2"
    local FILE="Go_terms.txt"
    local UNIQ_FILE="UniqueGO_terms.txt"

    log "Sorting and removing duplicates" "$log_file"
    find "$features_dir" -type d -name "sequence*" | while read -r folder_path; do
            in_file_path="$folder_path/$FILE"
            out_file_path="$folder_path/$UNIQ_FILE"
#            log "Sorting and removing duplicates from $in_file_path." "$log_file"
            sort "$in_file_path" | uniq > "$out_file_path"
#            log "Result saved to $out_file_path."
    done
}
