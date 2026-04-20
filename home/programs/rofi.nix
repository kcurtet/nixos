# ============================================================================
# Rofi Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.rofi-config;
in
{
  options.programs.rofi-config = {
    enable = lib.mkEnableOption "Rofi launcher configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme = "nord";
      pass = {
        enable = true;
        stores = [ "password-store" ];
      };
    };

    home.file.".config/rofi/nord.rasi" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/system/nixos-config/dotfiles/rofi/nord.rasi";
    };
  };
}
