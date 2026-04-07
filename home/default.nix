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
    ignore-scripts=true
    save-exact=true
    minimum-release-age=1440
    block-exotic-subdeps=true
    trus-policy=no-downgrade
    node-options=--permission
  '';

  # Emacs config (symlinked directly to repo, editable without rebuild)
  home.file.".config/emacs/early-init.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/emacs/early-init.el";
  home.file.".config/emacs/init.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/emacs/init.el";

  # PATH additions
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "foot -e nvim";
    TERMINAL = "foot";
  };

  # Default terminal for GNOME / XDG
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "foot.desktop" ];
    };
  };

  # Hyprland user configuration
  programs.hyprland-config.enable = true;

  # Hyprland-related programs
  programs.rofi-config.enable = true;
  programs.foot-config.enable = true;
  services.dunst-config.enable = true;
  gtk-config.enable = true;

  # User settings (can be overridden per-host)
  programs.git.settings = {
    user.name = lib.mkDefault "Kevin Curtet";
    user.email = lib.mkDefault "kcurtet@gmail.com";
    user.signingKey = lib.mkDefault "kcurtet@gmail.com";
  };

  # State version
  home.stateVersion = "26.05";
}
