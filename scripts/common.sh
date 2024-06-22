#!/bin/bash

write_log() {
  local message="$1"
  local log_file="$2"

  if [ -n "$log_file" ]; then
        echo "$message" >> "$log_file"
  fi
}

dump_log(){
  local log_file="$1"
  write_log  "$__log_msg__" "$log_file"
  __log_msg__=""
}

log() {
    local msg="$1"
    local log_file="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %T")
    local message="[${timestamp}] ${msg}"
    __log_msg__="${__log_msg__}${message}"$'\n'
    echo "$message"

    write_log "$message" "$log_file"
}

log_file_content() {
  local file_path="$1"
  local log_file="$2"

  if [ -f "$file_path" ]; then
    while IFS= read -r line; do
      log "$line" "$log_file"
    done < "$file_path"
  else
    log "ERROR: File not found: $file_path"
  fi
}

check_processors() {
  if [ -z "$PROCESSORS" ]; then
    log "Number of cores not provided, using default: $__processor__"
    PROCESSORS=$__processor__
  fi
}

check_mandatory_argument() {
    local arg_value=$1
    local arg_name=$2
    local arg_msg=$3

    if [ -z "$arg_value" ]; then
        log "ERROR: ${arg_name} is a mandatory argument. ${arg_msg}"
        log "Exiting..."
        exit 1
    fi
}

check_and_create_directory() {
    local dir_path=$1
    local dir_desc=$2

    if [ -n "$dir_path" ] && [ ! -d "$dir_path" ]; then
       mkdir -p "$dir_path"
       log "Created ${dir_desc}: '${dir_path}'"
    fi
}

check_file() {
    local file_path=$1
    if [ -n "$file_path" ] && [ ! -f "$file_path" ]; then
      log "ERROR: $file_path does not exist or is not a file. Exiting..."
      exit 1
    fi
}


activate_conda_env() {
  local env_file="$1"
  local conda_environment=$(awk '/name:/ { print $2 }' "$env_file")
  if conda env list | grep -q "^$conda_environment"; then
    eval "$(conda shell.bash hook)"; conda activate "$conda_environment"
  else
    log "ERROR: Conda environment $conda_environment doesn't exist. Exiting..."
    exit 1
  fi
}

deactivate_conda_env() {
  eval "$(conda shell.bash hook)"; conda deactivate
}

concatenate_files() {
    local input_files=("$@")
    local output_file="${input_files[-1]}"

    unset 'input_files[${#input_files[@]}-1]'

    cat "${input_files[@]}" > "$output_file"
}

clean_folder() {
    local folder="$1"
    rm -rf "$folder"/*
}

purge_folder() {
    local folder="$1"
    rm -rf "$folder"
}


