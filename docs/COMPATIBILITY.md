# Compatibility Notes

## Platform assumptions

- Android + Termux
- No root required for default setup
- Termux:X11 app installed for GUI display

## Architecture

Installer detects architecture (`arm64`, `arm`, `x86_64`, `x86`, unknown).
Unsupported/unknown architectures may still work with reduced reliability.

## Android limitations

- Background process limits vary by OEM ROM
- Aggressive battery optimizations may terminate desktop/session processes
- Input methods and clipboard support vary by keyboard and Android version

## Storage permissions

Shared storage access needs `termux-setup-storage` and Android permission approval.

## Audio

Audio routing depends on PulseAudio user session behavior and Android audio stack.
Behavior can vary by device/vendor.

## GPU acceleration

Full Linux desktop GPU acceleration in Termux is limited and device-dependent.
Expect software rendering or partial acceleration on many devices.

## Common Termux:X11 pitfalls

- Termux:X11 app not installed/opened
- DISPLAY not set correctly
- Missing desktop packages
- Session bus (DBus) issues

Use doctor mode:

```bash
./scripts/termux-desktop.sh doctor
```
