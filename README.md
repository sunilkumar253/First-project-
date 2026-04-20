# Termux Desktop Lab

> Proposed repository name: **termux-desktop-lab**

A modular, auditable, beginner-friendly Bash project to set up a Linux desktop-like environment inside **Termux** on Android, launched with **Termux:X11** and **XFCE**.

## What this project does

- Installs a core XFCE desktop stack in Termux
- Provides a clean CLI installer with modular components
- Supports optional add-ons (dev tools, themes, proot distro, optional lab tools)
- Includes doctor checks, dry-run mode, logs, backup-aware file handling, and uninstall/reset flow

## Safety and trust model

This repo is designed to be safer than random setup scripts:

- No obfuscation
- No primary `curl | bash` installation flow
- Readable, split-by-responsibility Bash scripts
- Explicit package plan shown before install
- Confirmation required unless `--yes` is passed
- Dry-run mode (`dry-run ...`) for preflight review
- Idempotent behavior (re-run installs safely)
- Backups before overwriting key files
- Optional lab tools isolated in a separate module and disabled by default

## Repository layout

```text
.
├── README.md
├── SECURITY.md
├── CONTRIBUTING.md
├── LICENSE
├── CHANGELOG.md
├── bin/
│   └── launch-xfce.sh
├── scripts/
│   ├── termux-desktop.sh
│   ├── uninstall.sh
│   ├── lib/
│   │   ├── common.sh
│   │   └── checks.sh
│   └── modules/
│       ├── core.sh
│       ├── devtools.sh
│       ├── themes.sh
│       ├── distro.sh
│       ├── lab.sh
│       └── doctor.sh
├── docs/
│   ├── TROUBLESHOOTING.md
│   └── COMPATIBILITY.md
├── config/
└── logs/
```

## Supported environment and limitations

- Android device with Termux installed
- Termux:X11 Android app required for GUI display
- Works without root (preferred)
- Performance varies by device, Android version, and vendor restrictions

See full notes: [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md)

## Install (safe local flow)

> Primary method intentionally avoids piping remote code to shell.

1. Clone the repository in Termux:
   ```bash
   pkg update && pkg install -y git
   git clone https://github.com/<your-user>/termux-desktop-lab.git
   cd termux-desktop-lab
   ```
2. Review scripts before running:
   ```bash
   ls -R
   ```
3. Optional dry-run preview:
   ```bash
   ./scripts/termux-desktop.sh dry-run install core
   ```
4. Install core module:
   ```bash
   ./scripts/termux-desktop.sh install core
   ```

## CLI usage

```bash
# Core install
./scripts/termux-desktop.sh install core

# Optional modules
./scripts/termux-desktop.sh install devtools
./scripts/termux-desktop.sh install themes
./scripts/termux-desktop.sh install distro debian
./scripts/termux-desktop.sh install lab

# Diagnostics
./scripts/termux-desktop.sh doctor

# Launch desktop
./scripts/termux-desktop.sh launch

# Uninstall/reset (config only)
./scripts/termux-desktop.sh uninstall

# Uninstall + remove tracked packages
./scripts/termux-desktop.sh uninstall --remove-packages

# Non-interactive mode
./scripts/termux-desktop.sh install core --yes

# Dry-run for any command
./scripts/termux-desktop.sh dry-run install devtools
```

## Core features

- Package update/upgrade
- XFCE + required userland dependencies
- Safe env configuration (`~/.termux-desktop/env.sh`)
- Launch flow for Termux:X11 + XFCE
- Doctor checks for common issues
- Log output in `logs/`

## Optional modules

- **devtools**: common development packages
- **themes**: UI/theme utilities
- **distro**: proot-distro user-space Linux image
- **lab**: clearly separated optional lab/security tools (authorized use only)

## Launching XFCE

```bash
./scripts/termux-desktop.sh launch
```

If app switching fails automatically, open the Termux:X11 app manually and rerun launch.

## Troubleshooting

See [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for black screen, audio, storage, and package issues.

## Uninstall/reset

- Remove project-managed config and links:
  ```bash
  ./scripts/termux-desktop.sh uninstall
  ```
- Also remove packages tracked by this installer:
  ```bash
  ./scripts/termux-desktop.sh uninstall --remove-packages
  ```

## Screenshots

- `docs/screenshots/desktop-home.png` (placeholder)
- `docs/screenshots/xfce-terminal.png` (placeholder)

## Security philosophy

- Default to transparency and least surprise
- Keep privileged/root assumptions out of default flow
- Isolate potentially sensitive tools
- Make actions auditable via logs and readable scripts

See [`SECURITY.md`](SECURITY.md).

## Roadmap

- Improve audio and clipboard integration notes per Android version
- Add optional profile presets for low-end devices
- Add export/import backup helper for desktop configs
- Expand doctor checks with richer environment diagnostics

## License

MIT (see [`LICENSE`](LICENSE)).
