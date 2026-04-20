#!/usr/bin/env bash
set -euo pipefail

# Themes module handles optional appearance packages.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

themes_install() {
  run_preflight_checks
  log_info "Installing optional theme/icon utilities."
  pkg_update_upgrade

  pkg_install_list "themes and icons" \
    lxappearance \
    adwaita-icon-theme \
    hicolor-icon-theme

  log_info "Themes module complete."
}
