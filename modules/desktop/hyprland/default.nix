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
  monitor-script = pkgs.writeShellScriptBin "monitor-daemon" ''
    INTERNAL="eDP-1"

    handle() {
      # Cuenta monitores conectados (excluyendo el interno)
      EXTERNAL_COUNT=$(hyprctl monitors -j | jq '[.[] | select(.name != "'$INTERNAL'")] | length')

      if [ "$EXTERNAL_COUNT" -gt 0 ]; then
        hyprctl keyword monitor "$INTERNAL,disable"
      else
        hyprctl keyword monitor "$INTERNAL,preferred,auto,1"
      fi
    }

    # Ejecutar una vez al inicio
    handle

    # Escuchar eventos de hyprland
    SOCKET="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    socat - UNIX-CONNECT:$SOCKET | while read -r event; do
      case "$event" in
        monitoradded*|monitorremoved*)
          handle
          ;;
      esac
    done
  '';
in
{
  options.desktop.hyprland-wayland = {
    enable = lib.mkEnableOption "Hyprland Wayland compositor";

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

    services.hyprwhspr-rs.enable = true;

    environment.systemPackages = with pkgs; [
      monitor-script

      # Notifications (system integration)
      libnotify

      # Audio control (system integration)
      pavucontrol

      # File manager
      thunar
      thunar-volman
      thunar-archive-plugin

      # Archive manager GUI
      file-roller

      # Archive backends
      p7zip
      unzip
      zip
      unrar

      # Screen sharing
      v4l-utils

      # XDG utilities
      xdg-utils
      xdg-user-dirs

      # terminal
      ghostty
    ];
  };
}
