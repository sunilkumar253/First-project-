#!/usr/bin/env bash
set -euo pipefail

# Doctor module performs non-destructive diagnostics for common setup issues.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

doctor_run() {
  run_preflight_checks

  log_info "Running desktop diagnostics..."

  local required_cmds=(startxfce4 pulseaudio dbus-daemon am)
  local cmd
  for cmd in "${required_cmds[@]}"; do
    if command_exists "${cmd}"; then
      log_info "Found command: ${cmd}"
    else
      log_warn "Missing command: ${cmd}"
    fi
  done

  if check_termux_x11_installed; then
    log_info "Termux:X11 command/package detected."
  else
    log_warn "Termux:X11 not detected in Termux packages. Install the Termux:X11 Android app manually."
  fi

  if [[ -f "${HOME}/.termux-desktop/env.sh" ]]; then
    log_info "Found environment file: ${HOME}/.termux-desktop/env.sh"
  else
    log_warn "Missing env file. Run core install first."
  fi

  if [[ -d "/sdcard" ]]; then
    log_info "Shared storage path detected. If file access fails, run: termux-setup-storage"
  else
    log_warn "Shared storage path not visible. Storage permission may be missing."
  fi

  log_info "Doctor checks complete."
}
