#!/usr/bin/env bash
set -euo pipefail

# This file centralizes shared helpers so each module stays focused on one job.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs"
STATE_DIR="${HOME}/.termux-desktop"
BACKUP_DIR="${STATE_DIR}/backups"
INSTALL_TRACK_FILE="${STATE_DIR}/installed-packages.txt"

DRY_RUN=0
ASSUME_YES=0
LOG_FILE=""

COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'

ensure_dir() {
  # We create required directories once to keep paths predictable and auditable.
  mkdir -p "$1"
}

init_logging() {
  # Logs are written to repo-local logs/ so users can inspect installer history.
  ensure_dir "${LOG_DIR}"
  ensure_dir "${STATE_DIR}"
  ensure_dir "${BACKUP_DIR}"

  if [[ -z "${LOG_FILE}" ]]; then
    LOG_FILE="${LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"
  fi

  touch "${LOG_FILE}"
}

_color_echo() {
  local color="$1"
  local level="$2"
  local message="$3"
  local timestamp
  timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  if [[ -t 1 ]]; then
    printf "%b[%s] [%s] %s%b\n" "${color}" "${timestamp}" "${level}" "${message}" "${COLOR_RESET}" | tee -a "${LOG_FILE}"
  else
    printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${message}" | tee -a "${LOG_FILE}"
  fi
}

log_info() {
  _color_echo "${COLOR_GREEN}" "INFO" "$1"
}

log_warn() {
  _color_echo "${COLOR_YELLOW}" "WARN" "$1"
}

log_error() {
  _color_echo "${COLOR_RED}" "ERROR" "$1"
}

abort() {
  # We always fail loudly with context instead of continuing in a bad state.
  log_error "$1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  local cmd="$1"
  command_exists "${cmd}" || abort "Missing required command: ${cmd}"
}

confirm_or_exit() {
  local prompt="$1"

  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    log_info "Auto-confirmed: ${prompt}"
    return 0
  fi

  read -r -p "${prompt} [y/N]: " answer
  case "${answer}" in
    y|Y|yes|YES)
      return 0
      ;;
    *)
      abort "Operation cancelled by user."
      ;;
  esac
}

run_cmd() {
  # Dry-run mode prints the exact command so users can audit before running.
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log_info "[DRY-RUN] $*"
    return 0
  fi
  log_info "Running: $*"
  "$@"
}

pkg_is_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

pkg_exists_in_repo() {
  # apt-cache is used to prevent failing on package names unavailable on some repos/arches.
  apt-cache show "$1" >/dev/null 2>&1
}

show_package_plan() {
  local title="$1"
  shift
  local pkg
  log_info "${title}"
  for pkg in "$@"; do
    printf '  - %s\n' "${pkg}" | tee -a "${LOG_FILE}"
  done
}

append_line_if_missing() {
  local line="$1"
  local file="$2"

  touch "${file}"
  if ! grep -Fxq "${line}" "${file}"; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      log_info "[DRY-RUN] Append to ${file}: ${line}"
    else
      printf '%s\n' "${line}" >> "${file}"
      log_info "Appended line to ${file}"
    fi
  fi
}

backup_file_if_exists() {
  local file="$1"

  if [[ -e "${file}" ]]; then
    local name
    name="$(basename "${file}")"
    local backup_path="${BACKUP_DIR}/${name}.$(date +%s).bak"
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      log_info "[DRY-RUN] Backup ${file} -> ${backup_path}"
    else
      cp -a "${file}" "${backup_path}"
      log_warn "Backed up ${file} to ${backup_path}"
    fi
  fi
}

record_installed_package() {
  local pkg="$1"
  ensure_dir "${STATE_DIR}"
  touch "${INSTALL_TRACK_FILE}"
  if ! grep -Fxq "${pkg}" "${INSTALL_TRACK_FILE}"; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      log_info "[DRY-RUN] Track package: ${pkg}"
    else
      printf '%s\n' "${pkg}" >> "${INSTALL_TRACK_FILE}"
    fi
  fi
}

pkg_update_upgrade() {
  # Updating metadata first reduces partial install failures and dependency drift.
  run_cmd pkg update -y
  run_cmd pkg upgrade -y
}

pkg_install_list() {
  local install_title="$1"
  shift

  local requested=("$@")
  local available=()
  local missing_repo=()
  local not_installed=()
  local pkg

  for pkg in "${requested[@]}"; do
    if pkg_exists_in_repo "${pkg}"; then
      available+=("${pkg}")
    else
      missing_repo+=("${pkg}")
    fi
  done

  if [[ "${#missing_repo[@]}" -gt 0 ]]; then
    log_warn "These packages are not available for this device/repo and will be skipped: ${missing_repo[*]}"
  fi

  for pkg in "${available[@]}"; do
    if ! pkg_is_installed "${pkg}"; then
      not_installed+=("${pkg}")
    fi
  done

  if [[ "${#not_installed[@]}" -eq 0 ]]; then
    log_info "All requested packages are already installed for: ${install_title}"
    return 0
  fi

  show_package_plan "Packages to install for ${install_title}:" "${not_installed[@]}"
  confirm_or_exit "Proceed with package installation?"

  run_cmd pkg install -y "${not_installed[@]}"

  for pkg in "${not_installed[@]}"; do
    record_installed_package "${pkg}"
  done
}
