# Security Policy

## Scope

This project is intended for:

- local personal Linux learning
- local desktop-like usage in Termux
- authorized lab/testing scenarios (optional module only)

This project is **not** intended to bypass permissions, attack systems, or enable unauthorized activity.

## Security principles

- No obfuscated scripts
- No hidden network bootstrap (`curl | bash`) as primary install path
- Modular scripts with clear responsibilities
- Confirmation before install actions (unless explicitly non-interactive)
- Dry-run mode for auditing commands
- Backup-aware file writes
- Optional lab tools isolated and clearly labeled

## Dependency sources

Prefer official Termux repositories and package manager workflows.
Third-party dependencies should be documented with rationale before inclusion.

## Reporting vulnerabilities

Please open a private security report if possible, or open an issue without posting exploit details publicly.
Include:

- impact summary
- affected script/module
- reproduction steps
- suggested mitigation (if known)

## Hardening guidance

- Keep Termux packages updated
- Avoid running unknown scripts from untrusted sources
- Review changes before running install commands
- Use `dry-run` mode first on production-like devices
