# ============================================================================
# Custom Shell Scripts
# ============================================================================
{ pkgs, flakePath }: {
  nboot = pkgs.writeShellScriptBin "nboot" ''
    sudo nixos-rebuild boot --flake ${flakePath}
  '';

  # Commit all changes and apply configuration
  nix-apply = pkgs.writeShellScriptBin "nix-apply" ''
    # Check if there are changes to commit
    if git -C ${flakePath} status --porcelain | grep -q .; then
      echo "Committing changes before switch..."
      git -C ${flakePath} add .
      git -C ${flakePath} commit -m "nix: system configuration update $(date +'%Y-%m-%d %H:%M:%S')"
    else
      echo "No changes to commit"
    fi
    sudo nixos-rebuild switch --flake ${flakePath}
  '';

  # Update flake inputs (nixpkgs, home-manager, etc.)
  nix-up = pkgs.writeShellScriptBin "nix-up" ''
    echo "Updating flake inputs..."
    nix flake update ${flakePath}
    echo "Done! Run 'nix-apply' to rebuild with the new inputs."
  '';
}
