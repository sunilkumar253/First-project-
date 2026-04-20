#!/usr/bin/env bash
set -euo pipefail

# This file contains environment and compatibility checks used by all commands.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

check_bash_version() {
  # Bash 4+ is required for arrays and safer parsing behavior used in this project.
  if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    abort "Bash 4+ is required. Current version: ${BASH_VERSION}"
  fi
}

check_termux_environment() {
  # This guard avoids running Android/Termux-specific commands in unsupported shells.
  if [[ "${PREFIX:-}" != *"com.termux"* ]]; then
    log_warn "PREFIX does not look like Termux. Some commands may fail outside Termux."
  fi
}

detect_arch() {
  local arch
  arch="$(uname -m)"
  case "${arch}" in
    aarch64) echo "arm64" ;;
    armv7l|arm) echo "arm" ;;
    x86_64) echo "x86_64" ;;
    i686|i386) echo "x86" ;;
    *) echo "unknown" ;;
  esac
}

check_termux_x11_installed() {
  # We detect both helper command and package metadata to reduce false negatives.
  if command_exists termux-x11; then
    return 0
  fi

  if pkg_is_installed termux-x11-nightly; then
    return 0
  fi

  return 1
}

print_compatibility_summary() {
  local arch
  arch="$(detect_arch)"
  log_info "Detected architecture: ${arch}"
  if [[ "${arch}" == "unknown" ]]; then
    log_warn "Unknown architecture. Install may still work but is not guaranteed."
  fi

  if check_termux_x11_installed; then
    log_info "Termux:X11 helper package/command detected."
  else
    log_warn "Termux:X11 helper not detected in Termux packages. Ensure the Android app is installed."
  fi
}

run_preflight_checks() {
  check_bash_version
  check_termux_environment
  require_command pkg
  require_command dpkg
  require_command apt-cache
  print_compatibility_summary
}
