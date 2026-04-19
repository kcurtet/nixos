# ============================================================================
# KDE Plasma 6 Desktop Configuration Module
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
    enable = lib.mkEnableOption "KDE Plasma 6 desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";

    environment.systemPackages = with pkgs; [
      # Audio control
      pavucontrol

      # Archive backends
      p7zip
      unzip
      zip
      unrar
    ];
  };
}
