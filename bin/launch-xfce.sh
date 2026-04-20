#!/usr/bin/env bash
set -euo pipefail

# This launcher starts Termux:X11-related services and then launches XFCE.
# It avoids root usage and keeps behavior explicit for easier troubleshooting.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/lib/common.sh
source "${SCRIPT_DIR}/../scripts/lib/common.sh"

init_logging

if [[ -f "${HOME}/.termux-desktop/env.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.termux-desktop/env.sh"
fi

: "${DISPLAY:=:0}"

require_command startxfce4
require_command pulseaudio

if command_exists termux-x11; then
  # This starts the local X server bridge in Termux userspace.
  run_cmd termux-x11 "${DISPLAY}" >/dev/null 2>&1 &
else
  log_warn "termux-x11 helper not found in PATH; assuming Termux:X11 app is installed manually."
fi

# Start Android activity when available so beginners do not need manual app switching.
if command_exists am; then
  run_cmd am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
fi

# PulseAudio is started in user mode for desktop app audio routing.
run_cmd pulseaudio --start --exit-idle-time=-1

# dbus-launch ensures XFCE services can communicate over a session bus.
if command_exists dbus-launch; then
  run_cmd dbus-launch --exit-with-session startxfce4
else
  run_cmd startxfce4
fi
