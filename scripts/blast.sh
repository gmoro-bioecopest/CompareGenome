#!/bin/bash

make_blast() {

  local db_dir="$1"

  find "$db_dir" -maxdepth 1 -type d  | while read -r folder_path; do
    if [ "$folder_path" != "$db_dir" ]; then
      local bn=$(basename "$folder_path")
      local db_file="$folder_path/$bn"
      makeblastdb -in "$db_file" -dbtype nucl >/dev/null
    fi 
  done

}

run_blast() {

  local input_dir="$1"
  local output_dir="$2"
  local db_dir="$3"
  local outfmt="$4"
  local ncores="$5"

  local ref_list="${input_dir}/ReferenceList.txt"
  local in_list="${input_dir}/InputLists.txt"

  while IFS= read -r rline; do

      rbn=$(basename "$rline")
      rbn=${rbn%.*}

      while IFS= read -r iline; do

        ibn=$(basename "$iline")
        ibn=${ibn%.*}
        odir="${output_dir}/${ibn}_Vs_${rbn}"
        ofile="${odir}/${ibn}_Vs_${rbn}_blast.txt"
        mkdir "$odir"
        db="$db_dir/$rbn/$rbn"

        blastn -db "$db" \
          -query "$iline" \
          -max_target_seqs 10 \
          -outfmt "$outfmt" \
          -num_threads "$ncores" \
          -out "$ofile"

        find "$odir" -type f -name "*_blast.txt" -exec gzip {} \;

      done < "$in_list"

  done < "$ref_list"

}


blastPairwise() {
  local folder_path="$1"
  local outfmt="$2"

  local dbase_fa_file="${folder_path}/Dbase.fa"
  local dbase_out_file="${folder_path}/Dbase"
  local query_fa_file="${folder_path}/Query.fa"
  local out_file="${folder_path}/Output.txt"

  check_file "${dbase_fa_file}"
  check_file "${query_fa_file}"

  makeblastdb -in "${dbase_fa_file}" -dbtype nucl -out "${dbase_out_file}" >/dev/null

  blastn -db "${dbase_out_file}" \
    -query "${query_fa_file}" \
    -max_target_seqs 10 \
    -outfmt "${outfmt}" \
    -out "${out_file}" \
    >/dev/null
}
