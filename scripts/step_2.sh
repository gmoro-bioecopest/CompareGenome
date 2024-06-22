#!/bin/bash

prepare_blast_input_files() {
    local features_dir="$1"
    local input_dir="$2"

    find "$features_dir" -type d -name "sequence_*" | while read -r folder_path; do
        out_file="$folder_path/geneseq.fa"
        header=">$(basename ${folder_path})"
        gene_file="$folder_path/GENE_geneseq.txt"
        ref_file="$input_dir/RefSeq.fa"
        in_list="$input_dir/InputLists.txt"

        echo "" >> "${gene_file}"
        body=$(<"${gene_file}")
        echo "${header}" > "${out_file}"
        echo "${body}" >> "${out_file}"
        cat "${out_file}" >> "${ref_file}"
        echo "${ref_file}" > "${in_list}"
    done

}

clean_db_dir() {
  local blast_dir="$1"
  local db_dir="$2"
  local input_dir="$3"

  local files=("basename.txt" "label.txt" "output.fa" "output2.fa")
  local out_file="${input_dir}/ReferenceList.txt"
  local tmp_dir="${blast_dir}/tempdb"

  clean_folder "${db_dir}"
  mv "${tmp_dir}"/* "${db_dir}"/

  for FILE in "${files[@]}"; do
    find "$db_dir" -type f -name "$FILE" -delete
  done

  find "$db_dir" -type f -exec echo {} >> "$out_file" \;

}

dbcode() {
  local blast_dir="$1"
  local db_dir="$2"

  local tmp_dir="${blast_dir}/tempdb"
  mkdir -p "${tmp_dir}"

  for file in "${db_dir}"/*; do
      bn=$(basename "$file")
      bn="${bn%.*}"
      dir_name="${tmp_dir}/${bn}"

      mkdir -p "${dir_name}"

      out_file="${dir_name}/output.fa"
      out2_file="${dir_name}/output2.fa"
      label_file="${dir_name}/label.txt"
      bn_file="${dir_name}/${bn}"

      cat "${file}" | sed -e '1!{/^>.*/d;}' > "${out_file}"
      sed '/^>/d' "${out_file}" > "${out2_file}"
      echo ">${bn}" > "${label_file}"
      cat "${label_file}" "${out2_file}" > "${bn_file}"
      echo "${bn}" > "${dir_name}/basename.txt"

  done
}

