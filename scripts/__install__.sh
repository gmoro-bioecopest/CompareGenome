#!/bin/bash



show_help() {
  cat << EOF
Usage: $0 [--num-cores/-n <num_cores>]

Install CompareGenome with the specified options.

Options:
  --num-cores, -n   Number of cores to use. Default: $__processor__
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
      --num-cores | -n)
          PROCESSORS="$2"
          shift
          shift
          ;;
      *)
        log "Unknown parameter passed: $1"
        show_help
        ;;
    esac
  done
}


check_conda() {
    if command -v conda &> /dev/null; then
      log "System requirements are satisfied: Conda is already installed."
    else
      log "ERROR: Conda is required but not installed."
      log "Please install Conda from https://docs.anaconda.com/free/anaconda/install/index.html"
      log "After installing Conda, please rerun the installation."
      log "Exiting..,"
      exit 1
    fi
}

create_conda_envs() {
  local env_file="$1"
  local conda_environment=$(awk '/name:/ { print $2 }' "$env_file")
  log "Creating environment ${conda_environment} from file ${env_file}"

  if conda env list | grep -q "^$conda_environment"; then
    log "Conda environment $conda_environment already exists. Trying to remove it.."
    conda env remove -n "$conda_environment"
    log "$conda_environment removed"
  fi

  eval "$(conda shell.bash hook)"; conda create -n "$conda_environment" -y

  if conda env list | grep -q "^$conda_environment"; then
    activate_conda_env "$env_file"
    while read -r line; do
      if [[ $line == -* ]]; then
        package=$(echo "$line" | awk -F= '{print $1}' | sed 's/^- //')
        conda install "${package}" -y
        check_package=$(conda list -n "$conda_environment" | grep -w "^$package " | tr -s ' ' | cut -d ' ' -f 1)

        if [ "$package" == "$check_package" ]; then
          log "Package $package has been installed"
        else
          log "WARNING: ${__appname__} failed in installing $package "
        fi

      fi
    done < <(awk '/dependencies:/,/^$/' "$env_file" | grep -v "^$")
    eval "$(conda shell.bash hook)"; conda deactivate
    log "Conda environment $conda_environment has been successfully created"
  else
    log "ERROR: $conda_environment is missing"
  fi
}


check_blast() {
  
  eval "$(conda shell.bash hook)"; conda activate BLAST_CG
  
  check_package=$(conda list -n BLAST_CG | grep -w blast | tr -s ' ' | cut -d ' ' -f 1)
  if [ "blast" != "$check_package" ]; then conda install -c bioconda blast -y; fi

  check_package=$(conda list -n BLAST_CG | grep -w blast | tr -s ' ' | cut -d ' ' -f 1)
  if [ "blast" != "$check_package" ]; then conda install -c conda-forge mamba -y; mamba install -c bioconda blast -y; fi

  check_package=$(conda list -n BLAST_CG | grep -w blast | tr -s ' ' | cut -d ' ' -f 1)
  if [ "blast" != "$check_package" ]; then 
          log "FATAL ERROR: ${__appname__} failed in installing blast"
          echo "FATAL ERROR: ${__appname__} failed in installing blast. Try to install it manually whithin the conda environment BLAST_CG" >>"${__check_install__}"
  fi
  
  eval "$(conda shell.bash hook)"; conda deactivate
}


install_r_packages() {
  local env_file="$1"
  activate_conda_env "$env_file"
  mkdir -p "${__install_dir__}/${__Rinstall_out__}"
  Rscript "${__check_r__}" "$INSTALL_DIR"  >$__Rout__ 2>$__Rerr__
  deactivate_conda_env
  
}

Installation_check() {
  local env_file="$1"
  local conda_environment=$(awk '/name:/ { print $2 }' "$env_file")
  log "Checking installation within the environment ${conda_environment}"


  if conda env list | grep -q "^$conda_environment"; then
   
    
    while read -r line; do
      if [[ $line == -* ]]; then
        package=$(echo "$line" | awk -F= '{print $1}' | sed 's/^- //')
        check_package=$(conda list -n "$conda_environment" | grep -w "^$package " | tr -s ' ' | cut -d ' ' -f 1)

        if [ "$package" == "$check_package" ]; then
          log "Package $package has been installed"
        else
          log "WARNING: ${__appname__} failed in installing $package "
          echo "WARNING:Package $package is missing.Try to install it manually whithin the conda environment $conda_environment" >>"${__check_install__}"
        fi

      fi
    done < <(awk '/dependencies:/,/^$/' "$env_file" | grep -v "^$")

  else
    log "FATAL ERROR: $conda_environment is missing"
    echo "FATAL ERROR: conda environment $conda_environment is missing." >>"${__check_install__}"
  fi
log_file_content "${__check_install__}"  
}

final_check() { 
 if [[ -z $(grep '[^[:space:]]' $__check_install__) ]] ; then
    log "All required packages have been succefully installed."
else
    log "WARNING: some of required packages seems to be not installed."
    cat "${__check_install__}"
    log_file_content "${__check_install__}"
fi 
  
}