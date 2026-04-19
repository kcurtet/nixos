# ============================================================================
# Sway Wayland Compositor Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.sway;
in
{
  options.desktop.sway = {
    enable = lib.mkEnableOption "Sway Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # Portal for Sway
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ];
    };

    environment.systemPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako
      wofi
    ];
  };
}
