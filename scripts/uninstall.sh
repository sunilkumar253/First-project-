#!/usr/bin/env bash
set -euo pipefail

# Uninstall removes project-managed config and optionally removes tracked packages.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

main() {
  init_logging
  local remove_packages="0"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        set_assume_yes
        ;;
      --remove-packages)
        remove_packages="1"
        ;;
      --dry-run)
        set_dry_run
        ;;
      *)
        abort "Unknown option for uninstall: $1"
        ;;
    esac
    shift
  done

  log_warn "This will remove project-created config files and optional launcher links."
  confirm_or_exit "Continue uninstall/reset?"

  backup_file_if_exists "${HOME}/.bashrc"

  local tracked_pkgs=()
  if [[ -f "${INSTALL_TRACK_FILE}" ]]; then
    mapfile -t tracked_pkgs < "${INSTALL_TRACK_FILE}"
  fi

  if [[ -L "${PREFIX}/bin/termux-desktop" || -f "${PREFIX}/bin/termux-desktop" ]]; then
    run_cmd rm -f "${PREFIX}/bin/termux-desktop"
  fi

  if [[ -L "${PREFIX}/bin/launch-xfce-termux" || -f "${PREFIX}/bin/launch-xfce-termux" ]]; then
    run_cmd rm -f "${PREFIX}/bin/launch-xfce-termux"
  fi

  if [[ -d "${HOME}/.termux-desktop" ]]; then
    run_cmd rm -rf "${HOME}/.termux-desktop"
    log_info "Removed ${HOME}/.termux-desktop"
  fi

  if [[ "${remove_packages}" -eq 1 ]]; then
    if [[ "${#tracked_pkgs[@]}" -gt 0 ]]; then
      show_package_plan "Tracked packages to remove:" "${tracked_pkgs[@]}"
      confirm_or_exit "Proceed with removing tracked packages?"
      run_cmd pkg uninstall -y "${tracked_pkgs[@]}"
    else
      log_info "No tracked package list found; skipping package removal."
    fi
  fi

  log_info "Uninstall/reset flow completed."
}

main "$@"
