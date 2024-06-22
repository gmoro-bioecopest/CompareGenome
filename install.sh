#!/bin/bash


. config/config.sh
. scripts/common.sh
. scripts/__install__.sh


INSTALL_DIR="${__install_dir__}"
LOG_FILE="${INSTALL_DIR}/install.${__timestamp__}.log"


parse_args "$@"
log "Installing ${__appname__} - V.${__version__} [${__release__}] by ${__authors__}"
log "${__description__}"

check_processors

log "Checking for Conda"
check_conda

log "Creating the conda environments"
create_conda_envs "$__env_compare_genome__"
create_conda_envs "$__env_blast__"

log "Checking packages installation"
echo '' > "${__check_install__}"
check_blast
install_r_packages "$__env_compare_genome__"
final_check

log "Please see log file: ${LOG_FILE}"
write_log  "$__log_msg__" "$LOG_FILE"



