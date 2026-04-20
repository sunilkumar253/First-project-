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
        ASSUME_YES=1
        ;;
      --remove-packages)
        remove_packages="1"
        ;;
      --dry-run)
        DRY_RUN=1
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

  if [[ -L "${PREFIX}/bin/termux-desktop" || -f "${PREFIX}/bin/termux-desktop" ]]; then
    run_cmd rm -f "${PREFIX}/bin/termux-desktop"
  fi

  if [[ -d "${HOME}/.termux-desktop" ]]; then
    run_cmd rm -rf "${HOME}/.termux-desktop"
    log_info "Removed ${HOME}/.termux-desktop"
  fi

  if [[ "${remove_packages}" -eq 1 && -f "${INSTALL_TRACK_FILE}" ]]; then
    mapfile -t pkgs < "${INSTALL_TRACK_FILE}"
    if [[ "${#pkgs[@]}" -gt 0 ]]; then
      show_package_plan "Tracked packages to remove:" "${pkgs[@]}"
      confirm_or_exit "Proceed with removing tracked packages?"
      run_cmd pkg uninstall -y "${pkgs[@]}"
    fi
  fi

  log_info "Uninstall/reset flow completed."
}

main "$@"
