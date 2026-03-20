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
  cfg = config.desktop.hyprland-wayland;
in
{
  options.desktop.hyprland-wayland = {
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

    # Register Hyprland session in GDM (using mkBefore to avoid conflicts)
    services.displayManager.sessionPackages = lib.mkBefore [ pkgs.hyprland ];

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
    # Note: User-specific packages (waybar, foot, rofi, dunst, grim, slurp, etc.)
    # are managed by Home Manager in home/programs/hyprland.nix
    environment.systemPackages = with pkgs; [
      # Notifications (system integration)
      libnotify

      # File manager
      thunar
      thunar-volman

      # Screen sharing
      v4l-utils

      # XDG utilities
      xdg-utils
      xdg-user-dirs
    ];
  };
}
