#!/bin/bash

add_missing_text() {
    local features_dir="$1"
    local log_file="$2"
    local files=("CDS_protein_id.txt" "note1.txt" "note2.txt" "note3.txt" )

    find "$features_dir" -type d -name "sequence_*" | while read -r folder_path; do

        for FILE in "${files[@]}"; do
            file_path="$folder_path/$FILE"
            if [ ! -f "$file_path" ] || [ ! -s "$file_path" ] ||  ! grep . "$file_path" ; then

              echo "Unclassified" > "$file_path"
              # log "Added missing $FILE in $folder_path" "$log_file"
            fi
        done
    done >/dev/null
}
