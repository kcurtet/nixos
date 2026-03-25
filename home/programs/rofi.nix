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
      pass = {
        enable = true;
        stores = [ "password-store" ];
      };
      theme = "${config.home.homeDirectory}/.config/rofi/nord.rasi";
    };
  };
}
