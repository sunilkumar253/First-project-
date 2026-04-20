# Contributing

Thanks for contributing.

## Ground rules

- Keep scripts readable and auditable
- Follow shellcheck-friendly style
- Use `set -euo pipefail`
- Split logic by responsibility (lib vs modules)
- Do not introduce `curl | bash` primary install patterns
- Keep optional lab/security tooling isolated and clearly documented

## Development workflow

1. Fork/branch from latest default branch
2. Make focused changes
3. Run checks locally:
   ```bash
   bash -n scripts/termux-desktop.sh
   bash -n scripts/uninstall.sh
   find scripts -type f -name "*.sh" -print0 | xargs -0 -n1 bash -n
   ```
4. Update docs for user-visible behavior changes
5. Open PR with:
   - summary
   - risk notes
   - test/validation notes

## Commit guidance

- Use clear, imperative commit messages
- Keep commits small and reviewable

## Code style

- Prefer explicit command checks
- Avoid silent failures
- Print meaningful user guidance on errors
