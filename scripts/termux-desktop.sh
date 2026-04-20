#!/usr/bin/env bash
set -euo pipefail

# Main CLI entrypoint; routes high-level commands to focused module scripts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=./modules/core.sh
source "${SCRIPT_DIR}/modules/core.sh"
# shellcheck source=./modules/devtools.sh
source "${SCRIPT_DIR}/modules/devtools.sh"
# shellcheck source=./modules/themes.sh
source "${SCRIPT_DIR}/modules/themes.sh"
# shellcheck source=./modules/distro.sh
source "${SCRIPT_DIR}/modules/distro.sh"
# shellcheck source=./modules/lab.sh
source "${SCRIPT_DIR}/modules/lab.sh"
# shellcheck source=./modules/doctor.sh
source "${SCRIPT_DIR}/modules/doctor.sh"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/termux-desktop.sh install core [--yes] [--dry-run]
  ./scripts/termux-desktop.sh install devtools [--yes] [--dry-run]
  ./scripts/termux-desktop.sh install themes [--yes] [--dry-run]
  ./scripts/termux-desktop.sh install distro [distro-name] [--yes] [--dry-run]
  ./scripts/termux-desktop.sh install lab [--yes] [--dry-run]
  ./scripts/termux-desktop.sh doctor [--dry-run]
  ./scripts/termux-desktop.sh launch [--dry-run]
  ./scripts/termux-desktop.sh uninstall [--yes] [--remove-packages] [--dry-run]
  ./scripts/termux-desktop.sh dry-run <any-command...>
USAGE
}

install_prefix_command() {
  if [[ "${1:-}" == "dry-run" ]]; then
    set_dry_run
    shift
    set -- "$@"
  fi

  [[ $# -gt 0 ]] || { usage; exit 1; }

  local cmd="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        set_assume_yes
        ;;
      --dry-run)
        set_dry_run
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  init_logging

  case "${cmd}" in
    install)
      local module="${1:-}"
      shift || true
      case "${module}" in
        core)
          core_install
          ;;
        devtools)
          devtools_install
          ;;
        themes)
          themes_install
          ;;
        distro)
          distro_install "${1:-debian}"
          ;;
        lab)
          lab_install
          ;;
        *)
          abort "Unknown install module: ${module:-<missing>}"
          ;;
      esac
      ;;
    doctor)
      doctor_run
      ;;
    launch)
      run_cmd "${REPO_ROOT}/bin/launch-xfce.sh"
      ;;
    uninstall)
      run_cmd "${SCRIPT_DIR}/uninstall.sh" "${@}"
      ;;
    *)
      usage
      abort "Unknown command: ${cmd}"
      ;;
  esac
}

install_prefix_command "$@"
