{ pkgs }:
{
  nboot = pkgs.writeShellScriptBin "nboot" ''
    # Auto-detect flake directory from git repository
    FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/system/nixos-config")
    sudo nixos-rebuild boot --flake "$FLAKE_DIR"
  '';

  # Commit all changes and apply configuration
  nix-apply = pkgs.writeShellScriptBin "nix-apply" ''
    # Auto-detect flake directory from git repository
    FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/system/nixos-config")
    # Check if there are changes to commit
    if git -C "$FLAKE_DIR" status --porcelain | grep -q .; then
      echo "Uncommitted changes detected in $FLAKE_DIR:"
      git -C "$FLAKE_DIR" --no-pager status --short
      echo "Diff:"
      git -C "$FLAKE_DIR" --no-pager diff --no-color || true

      # Allow non-interactive auto-commit via environment variable or --yes flag
      if [ "${NIX_APPLY_AUTO:-}" = "1" ] || [ "${1:-}" = "--yes" ]; then
        echo "Auto-commit enabled"
        git -C "$FLAKE_DIR" add .
        git -C "$FLAKE_DIR" commit -m "nix: system configuration update $(date +'%Y-%m-%d %H:%M:%S')"
      else
        read -p "Commit these changes and continue? [y/N]: " answer
        case "$answer" in
          [Yy]* )
            git -C "$FLAKE_DIR" add .
            git -C "$FLAKE_DIR" commit -m "nix: system configuration update $(date +'%Y-%m-%d %H:%M:%S')"
            ;;
          * )
            echo "Skipping commit. Aborting rebuild."
            exit 1
            ;;
        esac
      fi
    else
      echo "No changes to commit"
    fi
    sudo nixos-rebuild switch --flake "$FLAKE_DIR"
  '';

  # Update flake inputs (nixpkgs, home-manager, etc.)
  nix-up = pkgs.writeShellScriptBin "nix-up" ''
    # Auto-detect flake directory from git repository
    FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/system/nixos-config")
    echo "Updating flake inputs..."
    nix flake update --flake "$FLAKE_DIR"
    echo "Done! Run 'nix-apply' to rebuild with the new inputs."
  '';
}
