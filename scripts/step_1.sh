#!/bin/bash

create_missing_files() {
    local features_dir="$1"
    local log_file="$2"
    local files=("GENE_geneID.txt" "CDS_note.txt" "GENE_note_gene.txt" "CDS_product.txt" "CDS_protein_id.txt")
    local cds_file="CDS_NumberID.txt"

    find "$features_dir" -type d -name "sequence_*" | while read -r folder_path; do

        for FILE in "${files[@]}"; do
            file_path="$folder_path/$FILE"
            if [ ! -f "$file_path" ]; then
                case "$FILE" in
                    "GENE_geneID.txt")
                        local seqNo=$(<"$folder_path/$cds_file")
                        echo "Unclassified_$seqNo" > "$file_path"
                        ;;
                    *)
                        echo 'Unclassified' > "$file_path"
                        ;;
                esac
                 #log "Added missing $FILE in $folder_path" "$log_file"
            fi
        done
    done
}

create_csv_files() {
  local features_dir="$1"

  find "${features_dir}/CDS" -type f -name 'CDS_geneID.txt' > "${features_dir}/cds_geneID.csv"
  find "${features_dir}/gene" -type f -name 'GENE_geneID.txt' > "${features_dir}/gene_geneID.csv"
  find "${features_dir}/CDS" -type f -name 'CDS_locus_tag.txt' > "${features_dir}/cds_locus_tag.csv"
  find "${features_dir}/gene" -type f -name 'GENE_locus_tag.txt' > "${features_dir}/gene_locus_tag.csv"
  find "${features_dir}/CDS" -type f -name 'CDS_db_xref.txt' > "${features_dir}/cds_db_xref.csv"
  find "${features_dir}/gene" -type f -name 'GENE_db_xref.txt' > "${features_dir}/gene_db_xref.csv"
  find "${features_dir}/CDS" -type f -name 'CDS_NumberID.txt' > "${features_dir}/CDS_NumberID.csv"

}

clean_tmp_files() {
  local features_dir="$1"

  find "${features_dir}" -maxdepth 1 -name "*.csv" -type f -delete
  find "${features_dir}" -maxdepth 1 -name "*.txt" -type f -delete
  find "${features_dir}/CDS" -maxdepth 1 -exec mv {} "${features_dir}" \;

  purge_folder "${features_dir}/CDS"
  purge_folder "${features_dir}/gene"
}

check_and_remove_empty_folders() {
  local features_dir="$1"
  local log_file="$2"

  find "$features_dir" -maxdepth 1 -type d -name "sequence_*" | while read -r folder_path; do
    local FILE="$folder_path/GENE_geneseq.txt"
    if [[ -z $(grep '[^[:space:]]' $FILE) ]]; then
      #log "$folder_path is empty. Removing folder" "$log_file"
      rm -rf "$folder_path"
    fi

  done
}

process_annotation_file() {
  local input_file="$1"
  local output_file="$2"

  if [ -f "$input_file" ]; then
    uniq "$input_file" > "$output_file"
    sed "s/ /_/g" "$output_file" >"$output_file".tempnote.txt
    sed "s/[^[:alnum:]_]//g" "$output_file".tempnote.txt >"$output_file".tempnote2.txt
    sed "s/_/ /g" "$output_file".tempnote2.txt >"$output_file"
    rm "$output_file".tempnote* 
  fi
}

concatenate_annotation_info() {
  local features_dir="$1"
  local log_file="$2"

  find "$features_dir" -maxdepth 1 -type d -name "sequence_*" | while read -r folder_path; do
    process_annotation_file "$folder_path/CDS_product.txt" "$folder_path/note1.txt"
    process_annotation_file "$folder_path/GENE_note_gene.txt" "$folder_path/note2.txt"
    process_annotation_file "$folder_path/CDS_note.txt" "$folder_path/note3.txt"
  done
}

add_basename_files() {
  local features_dir="$1"
  local log_file="$2"

  find "$features_dir" -maxdepth 1 -type d -name "sequence_*" | while read -r folder_path; do
    base_name=$(basename "$folder_path")
    base_file="$folder_path/basename.txt"
    echo "$base_name" > "$base_file"
#    log "Added $base_file"
  done
}


