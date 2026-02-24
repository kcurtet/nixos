# ============================================================================
# Custom Shell Scripts
# ============================================================================
pkgs: flakePath: {
  nswitch = pkgs.writeShellScriptBin "nswitch" ''
    sudo nixos-rebuild switch --flake ${flakePath}
  '';

  nboot = pkgs.writeShellScriptBin "nboot" ''
    sudo nixos-rebuild boot --flake ${flakePath}
  '';

  nupdate = pkgs.writeShellScriptBin "nupdate" ''
    nix flake update ${flakePath}
    sudo nixos-rebuild switch --flake ${flakePath}
  '';
}
