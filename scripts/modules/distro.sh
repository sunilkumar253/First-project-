#!/usr/bin/env bash
set -euo pipefail

# Distro module installs Linux distributions inside user-space via proot-distro.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

distro_install() {
  run_preflight_checks
  log_info "Installing optional proot-distro module."
  pkg_update_upgrade

  pkg_install_list "proot-distro" proot-distro

  local distro_name="${1:-debian}"

  if proot-distro list | grep -qi "^\s*${distro_name}\b"; then
    log_info "Distro '${distro_name}' already exists; skipping install."
    return 0
  fi

  log_warn "This installs a user-space distro image. Storage usage may be significant."
  confirm_or_exit "Install proot distro '${distro_name}' now?"

  run_cmd proot-distro install "${distro_name}"
  log_info "Distro module complete. Enter with: proot-distro login ${distro_name}"
}
