# ============================================================================
# KDE Plasma Desktop Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.kde;
in
{
  options.desktop.kde = {
    enable = lib.mkEnableOption "KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs; [
      # KDE utilities
      kdePackages.konsole
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.spectacle
      kdePackages.gwenview
      kdePackages.kate
      kdePackages.okular
      kdePackages.filelight
      kdePackages.ksystemlog

      # Audio control
      pavucontrol
    ];
  };
}
