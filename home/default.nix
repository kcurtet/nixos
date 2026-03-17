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

  # Autojump for directory navigation
  programs.autojump.enable = true;

  home.file.".npmrc".text = ''
    //registry.npmjs.org/:_authToken=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
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

  # Set Fish as the default shell
  home.shell = pkgs.fish;

  # User settings (can be overridden per-host)
  programs.git.settings = {
    user.name = lib.mkDefault "Kevin Curtet";
    user.email = lib.mkDefault "kcurtet@gmail.com";
    user.signingKey = lib.mkDefault "kcurtet@gmail.com";
  };

  # State version
  home.stateVersion = "26.05";
}
