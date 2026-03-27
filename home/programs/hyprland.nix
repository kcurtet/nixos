# ============================================================================
# Hyprland Home Manager Configuration
# ============================================================================
# Hyprland window manager settings live in ~/.config/hypr/hyprland.conf (manual).
# This file provides supporting programs, packages, and theming only.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hyprland-config;
in
{
  options.programs.hyprland-config = {
    enable = lib.mkEnableOption "Hyprland user configuration";
  };

  config = lib.mkIf cfg.enable {
    # ── Dotfiles (symlinked directly to repo, editable without rebuild) ──
    home = {
      file = {
        # Cursor theme index with proper Directories field (fixes hyprtoolkit warning)
        ".icons/default/index.theme".text = lib.mkForce ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=Bibata-Modern-Classic
          Directories=
        '';
        ".config/hypr/hyprland.conf" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/hyprland.conf";
        };

        ".config/hypr/scripts/dunst-waybar.sh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/dunst-waybar.sh";
        };
        ".config/hypr/scripts/keybinds.sh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/keybinds.sh";
        };
        ".config/hypr/scripts/powermenu.sh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/powermenu.sh";
        };
        ".config/hypr/scripts/alarm.sh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/alarm.sh";
        };
        ".local/bin/alarm" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/alarm.sh";
        };
        ".config/hypr/scripts/gcal-waybar.sh" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/gcal-waybar.sh";
        };
        ".config/hypr/waybar.conf" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/waybar.conf";
        };
        ".config/rofi/nord.rasi" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/rofi/nord.rasi";
        };
        ".config/wallpaper.jpg" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/wallpapers/merry-hd.jpg";
        };
        ".config/waybar/config" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/config.json";
        };
        ".config/waybar/style.css" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/style.css";
        };
      };
      packages = with pkgs; [
        # Screenshots
        grim
        slurp

        # Clipboard
        wl-clipboard
        cliphist

        # Audio/Brightness
        pamixer
        brightnessctl

        # Media control
        playerctl

        # Screen locker
        swaylock-effects

        # Logout menu
        wlogout

        # Color picker
        hyprpicker

        # Wallpaper
        swww

        # Network manager GUI
        networkmanagerapplet
      ];
      pointerCursor = {
        gtk = {
          enable = true;
        };
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };

    # Waybar — config managed via dotfiles (waybar/config.json + style.css)
    programs.waybar.enable = true;

    # Ensure screenshot directory exists
    xdg.userDirs.extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
