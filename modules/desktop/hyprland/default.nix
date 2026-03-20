# ============================================================================
# Hyprland Desktop Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.hyprland;
in
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland Wayland compositor";

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

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        wl-clipboard
        waybar
        rofi-wayland
        swaybg
        swaylock-effects
        wlogout
        kanshi
        hyprpicker
        grim
        slurp
      ];
      description = "Extra packages to install with Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Wayland compositor
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # XDG portal for Wayland
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Keyboard settings
    services.xserver.xkb = {
      inherit (cfg.xkb) layout variant;
    };

    # Required for Wayland compositors
    security.polkit.enable = true;
    services.dbus.enable = true;

    # Install packages
    environment.systemPackages = cfg.extraPackages;

    # Dconf for settings
    programs.dconf.enable = true;
  };
}
