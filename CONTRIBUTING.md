Thank you for contributing!

This repository uses Nix flakes and sops for secrets. Please follow these guidelines to keep the repo healthy.

Quick checks (recommended before committing):

- Formatting and linting (via the dev shell):
  nix develop
  nixfmt-tree --check .
  statix check .
  deadnix .

- Run flake checks:
  nix --extra-experimental-features 'nix-command flakes' flake check

Git hooks
---------
A sample pre-commit hook is provided at `.githooks/pre-commit` to run the above checks locally. To enable it:

  git config core.hooksPath .githooks

The hook requires `nix` to be available and may be slow on first run (it will download required tools).

CI
--
A GitHub Actions workflow is added at `.github/workflows/ci.yml`. It runs `nix flake check` and basic formatter/linter checks for every push and PR.

Scripts
-------
- `nix-apply` (packaged in `scripts/default.nix`) now prompts before committing any uncommitted changes. For non-interactive usage, set the environment variable `NIX_APPLY_AUTO=1` or pass `--yes`:

  NIX_APPLY_AUTO=1 nix-apply
  # or
  nix-apply --yes

Secrets
-------
Secrets are managed with sops/sops-nix. Do not commit plaintext secrets. The `secrets/secrets.yaml` file is encrypted and should remain as-is. (You indicated you will manage secrets yourself.)

If you need help setting up your environment (Nix, direnv), check the README and the `nix develop` dev shell.
