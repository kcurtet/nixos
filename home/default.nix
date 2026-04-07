# ============================================================================
# Home Manager Configuration
# ============================================================================
{
  config,
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

  home = {
    file = {
      ".npmrc".text = ''
        prefix=${config.home.homeDirectory}/.npm-global
        minimumReleaseAge = 1440
      '';
      ".config/emacs/early-init.el".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/emacs/early-init.el";
      ".config/emacs/init.el".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/emacs/init.el";
    };
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.bun/bin"
      "$HOME/.npm-global/bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "ghostty -e nvim";
      TERMINAL = "ghostty";
    };
    stateVersion = "26.05";
  };
}
