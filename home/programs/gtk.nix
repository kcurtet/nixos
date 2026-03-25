# ============================================================================
# GTK Theme Configuration (Nord)
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.gtk-config;
in
{
  options.gtk-config = {
    enable = lib.mkEnableOption "GTK theme configuration with Nord theme";
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
      font = {
        name = "Sans";
        size = 11;
      };
    };
  };
}
