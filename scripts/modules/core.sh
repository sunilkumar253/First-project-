#!/usr/bin/env bash
set -euo pipefail

# Core module installs the desktop baseline and user config in a repeatable way.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/checks.sh
source "${SCRIPT_DIR}/../lib/checks.sh"

core_install() {
  run_preflight_checks

  log_info "Installing core desktop components."
  pkg_update_upgrade

  # x11-repo is required for Termux X11-related packages.
  pkg_install_list "core repository" x11-repo

  # Core desktop stack kept intentionally small for stability.
  pkg_install_list "XFCE core" \
    xfce4 \
    xfce4-terminal \
    dbus \
    pulseaudio \
    pavucontrol \
    thunar \
    nano

  ensure_dir "${HOME}/.termux-desktop"
  ensure_dir "${HOME}/.config"

  local env_file="${HOME}/.termux-desktop/env.sh"
  backup_file_if_exists "${env_file}"
  local env_template="${REPO_ROOT}/config/env.example.sh"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log_info "[DRY-RUN] Write ${env_file}"
  else
    if [[ -f "${env_template}" ]]; then
      cp "${env_template}" "${env_file}"
    else
      cat > "${env_file}" <<'ENVEOF'
#!/usr/bin/env bash
# Environment defaults for Termux + XFCE through Termux:X11.
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
ENVEOF
    fi
    chmod +x "${env_file}"
    log_info "Created ${env_file}"
  fi

  # We append safely so existing user aliases/config remain intact.
  append_line_if_missing "# Termux desktop environment" "${HOME}/.bashrc"
  append_line_if_missing "[ -f \"${env_file}\" ] && source \"${env_file}\"" "${HOME}/.bashrc"

  # Symlinks in PREFIX/bin provide predictable command paths for users.
  local cli_link="${PREFIX}/bin/termux-desktop"
  local launch_link="${PREFIX}/bin/launch-xfce-termux"
  local cli_target="${REPO_ROOT}/scripts/termux-desktop.sh"
  local launch_target="${REPO_ROOT}/bin/launch-xfce.sh"

  if [[ -e "${cli_link}" && ! -L "${cli_link}" ]]; then
    backup_file_if_exists "${cli_link}"
  fi
  if [[ -e "${launch_link}" && ! -L "${launch_link}" ]]; then
    backup_file_if_exists "${launch_link}"
  fi

  run_cmd ln -sfn "${cli_target}" "${cli_link}"
  run_cmd ln -sfn "${launch_target}" "${launch_link}"

  log_info "Core install complete. Run: ./scripts/termux-desktop.sh launch"
}
