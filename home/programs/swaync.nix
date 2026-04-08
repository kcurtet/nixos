# ============================================================================
# SwayNC Notification Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.swaync-config;
in
{
  options.services.swaync-config = {
    enable = lib.mkEnableOption "SwayNotificationCenter configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        swaynotificationcenter
      ];
      file = {
        ".config/swaync/config.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/swaync/config.json";
        };
        ".config/swaync/style.css" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/swaync/style.css";
        };
      };
    };
  };
}
