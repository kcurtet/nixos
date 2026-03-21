# ============================================================================
# Home Manager Configuration
# ============================================================================
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./themes/nord.nix
    ./programs
    ./packages
    ./services
    ./aliases.nix
  ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  # PATH additions
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Hyprland user configuration
  programs.hyprland-config.enable = true;

  # User settings (can be overridden per-host)
  programs.git.settings = {
    user.name = lib.mkDefault "Kevin Curtet";
    user.email = lib.mkDefault "kcurtet@gmail.com";
    user.signingKey = lib.mkDefault "kcurtet@gmail.com";
  };

  # State version
  home.stateVersion = "26.05";
}
