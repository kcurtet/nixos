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
    home.file.".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/hyprland.conf";
    home.file.".config/hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/hyprpaper.conf";
    home.file.".config/wallpaper.jpg".source = ../../dotfiles/wallpapers/merry-hd.jpg;
    home.file.".config/hypr/waybar.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/waybar.conf";
    home.file.".config/hypr/scripts/keybinds.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/keybinds.sh";
    home.file.".config/hypr/scripts/powermenu.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/powermenu.sh";
    home.file.".config/hypr/scripts/dunst-waybar.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/scripts/dunst-waybar.sh";
    home.file.".config/rofi/nord.rasi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/rofi/nord.rasi";
    home.file.".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/config.jsonc";
    home.file.".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/style.css";

    # Cursor theme
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # GTK theme (Nord)
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

    # Waybar — config managed via dotfiles (waybar/config.jsonc + style.css)
    programs.waybar.enable = true;

    # Foot terminal (default terminal for Hyprland)
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          dpi-aware = "yes";
          login-shell = "yes";
        };

        colors-dark = {
          background = "2e3440";
          foreground = "d8dee9";
          regular0 = "3b4252";
          regular1 = "bf616a";
          regular2 = "a3be8c";
          regular3 = "ebcb8b";
          regular4 = "81a1c1";
          regular5 = "b48ead";
          regular6 = "88c0d0";
          regular7 = "e5e9f0";
          bright0 = "4c566a";
          bright1 = "bf616a";
          bright2 = "a3be8c";
          bright3 = "ebcb8b";
          bright4 = "81a1c1";
          bright5 = "b48ead";
          bright6 = "8fbcbb";
          bright7 = "eceff4";
        };
      };
    };

    # Rofi configuration
    programs.rofi = {
      enable = true;
      pass = {
        enable = true;
        stores = [ "password-store" ];
      };
      theme = "${config.home.homeDirectory}/.config/rofi/nord.rasi";
    };

    # Dunst notification configuration
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 11";
          frame_color = "#81a1c1";
          separator_color = "#4c566a";
        };
        urgency_low = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_normal = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_critical = {
          background = "#bf616a";
          foreground = "#eceff4";
        };
      };
    };

    # User packages
    home.packages = with pkgs; [
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
      hyprpaper

      # Network manager GUI
      networkmanagerapplet
    ];

    # Ensure screenshot directory exists
    xdg.userDirs.extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
