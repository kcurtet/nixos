# ============================================================================
# GNOME Desktop Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";

    gdm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GDM display manager (shared with other desktops)";
    };

    keyring = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GNOME Keyring";
    };

    xkb = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard variant";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb.layout = cfg.xkb.layout;
      xkb.variant = cfg.xkb.variant;
      desktopManager.gnome.enable = true;
    };

    services.displayManager.gdm.enable = cfg.gdm;
    services.gnome.gnome-keyring.enable = cfg.keyring;

    # Required for GNOME on Wayland
    services.dbus.enable = true;
  };
}
