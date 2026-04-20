# Troubleshooting

## 1) Black screen in Termux:X11

Checks:

- Ensure Termux:X11 app is installed on Android
- Run doctor:
  ```bash
  ./scripts/termux-desktop.sh doctor
  ```
- Ensure `DISPLAY=:0` is set (`~/.termux-desktop/env.sh`)
- Start launch flow again:
  ```bash
  ./scripts/termux-desktop.sh launch
  ```

If still black:

- Open Termux:X11 app manually before launching XFCE
- Restart Termux app and rerun launch
- Re-run core install in dry-run and normal mode to verify dependencies

## 2) Audio not working

- Verify PulseAudio package installed
- Relaunch desktop to restart PulseAudio session
- Confirm no stale pulseaudio process is stuck

## 3) Storage access issues

Run:

```bash
termux-setup-storage
```

Then grant permission in Android prompt.

## 4) Clipboard issues

Clipboard behavior varies by Android version and app focus handling.
Expect partial behavior depending on keyboard/app constraints.

## 5) Package not found

Some packages differ by architecture/repo availability.
The installer warns and skips unavailable packages by design.

## 6) Slow UI or rendering lag

- Lower XFCE visual effects
- Close heavy apps
- Use a lighter module mix (core only)
- Device GPU/driver support on Android is limited

## 7) Re-run safety

Re-running install commands is expected to be safe/idempotent.
Existing packages are skipped and important files are backup-aware.
