#!/usr/bin/env bash
set -euo pipefail

# Lab module is intentionally isolated and disabled by default for safer usage boundaries.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

lab_install() {
  run_preflight_checks

  log_warn "LAB TOOLS NOTICE: Install only for authorized labs/testing on systems you own or are permitted to test."
  confirm_or_exit "Do you understand and want to continue with optional lab tools?"

  pkg_update_upgrade
  pkg_install_list "optional lab tools" \
    nmap \
    whois \
    netcat-openbsd

  log_info "Optional lab tools module complete."
}
