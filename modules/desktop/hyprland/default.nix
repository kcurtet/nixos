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
  };

  config = lib.mkIf cfg.enable {
    # Wayland session for Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Keyboard settings for Hyprland
    services.xserver = {
      enable = true;
      xkb.layout = cfg.xkb.layout;
      xkb.variant = cfg.xkb.variant;
    };

    # Required for Wayland compositors
    services.dbus.enable = true;
    hardware.graphics.enable = true;

    # Portal settings for Wayland
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    # System packages for Hyprland ecosystem
    environment.systemPackages = with pkgs; [
      # Status bar
      waybar

      # Terminal
      foot

      # Wallpaper
      swww

      # Application launcher
      rofi

      # Notifications
      dunst
      libnotify

      # File manager
      thunar
      xfce.thunar-volman

      # Clipboard manager
      wl-clipboard
      cliphist

      # Volume/brightness controls
      pamixer
      brightnessctl

      # Screen locking
      swaylock-effects

      # Screenshot tool
      grim
      slurp

      # Screen sharing
      v4l-utils

      # Other utilities
      xdg-utils
      xdg-user-dirs
    ];
  };
}
