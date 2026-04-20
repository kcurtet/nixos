# ============================================================================
# Waybar Configuration
# ============================================================================
# Waybar config lives in dotfiles/waybar/ (symlinked, editable without rebuild).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.waybar-config;
in
{
  options.programs.waybar-config = {
    enable = lib.mkEnableOption "Waybar status bar configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        waybar
      ];

      file = {
        ".config/waybar/config.jsonc" = {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/config-sway.json";
        };
        ".config/waybar/style.css" = {
          source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/style.css";
        };
      };
    };
  };
}
