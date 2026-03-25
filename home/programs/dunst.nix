# ============================================================================
# Dunst Notification Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dunst-config;
in
{
  options.services.dunst-config = {
    enable = lib.mkEnableOption "Dunst notification daemon configuration";
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 11";
          frame_color = "#81a1c1";
          separator_color = "#4c566a";
        };
        urgency_low = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_normal = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_critical = {
          background = "#bf616a";
          foreground = "#eceff4";
        };
      };
    };
  };
}
