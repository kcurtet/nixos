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

    xkb = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "es";
        description = "Keyboard layout";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "cat";
        description = "Keyboard variant";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export GDK_BACKEND=wayland,x11
        export QT_QPA_PLATFORM="wayland;xcb"
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export CLUTTER_BACKEND=wayland
        export GTK_IM_MODULE=simple
        export XCURSOR_SIZE=24
        export XCURSOR_THEME=Bibata-Modern-Classic
        export WLR_NO_HARDWARE_CURSORS = "1";
        export WLR_RENDERER = "vulkan";
        export DXVK_HDR = "1";
        export ENABLE_GAMESCOPE_WSI = "1";
        export WINE_FULLSCREEN_FSR = "1";
      '';
    };

    # Keyboard settings
    services.xserver = {
      xkb.layout = cfg.xkb.layout;
      xkb.variant = cfg.xkb.variant;
    };

    # Required for Wayland compositors
    services.dbus.enable = true;
    hardware.graphics.enable = true;

    # Portal for Sway
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config.sway = {
        default = lib.mkForce [
          "wlr"
          "gtk"
        ];
      };
    };

    # Polkit authentication agent
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      # Sway utilities
      swaylock
      swayidle
      swaybg

      # Notifications
      libnotify

      # Audio control
      pavucontrol

      # File manager
      thunar
      thunar-volman
      thunar-archive-plugin

      # Archive backends
      p7zip
      unzip
      zip
      unrar
      file-roller

      # XDG utilities
      xdg-utils
      xdg-user-dirs

      # Screen sharing
      v4l-utils

      # Terminal
      foot
    ];
  };
}
