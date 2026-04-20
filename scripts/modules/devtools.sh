#!/usr/bin/env bash
set -euo pipefail

# Devtools module adds common local development utilities.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

devtools_install() {
  run_preflight_checks
  log_info "Installing optional developer toolset."
  pkg_update_upgrade

  pkg_install_list "developer tools" \
    git \
    curl \
    wget \
    vim \
    tmux \
    openssh \
    build-essential \
    python \
    nodejs-lts

  log_info "Developer tools module complete."
}
