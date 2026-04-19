# ============================================================================
# Sway Home Manager Configuration
# ============================================================================
# Sway config lives in dotfiles/sway/config (symlinked, editable without rebuild).
# This file provides supporting programs, packages, and theming.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.sway-config;
in
{
  options.programs.sway-config = {
    enable = lib.mkEnableOption "Sway user configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
        # Sway config (symlinked to dotfiles)
        ".config/sway/config" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/sway/config";
        };

        # Waybar config for Sway (separate from Hyprland's)
        ".config/waybar/config-sway.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/waybar/config-sway.json";
        };

        # Wallpaper
        ".config/wallpaper.jpg" = {
          source = ../../dotfiles/wallpapers/merry-hd.jpg;
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
        swaylock

        # Idle daemon
        swayidle

        # Logout menu
        wlogout

        # Wallpaper
        swaybg

        # Network manager GUI
        networkmanagerapplet

        # App launcher (dmenu-style for sway)
        wofi
      ];

      # pointerCursor handled by hyprland.nix (both always enabled)
    };

    # Waybar — config managed via dotfiles
    programs.waybar.enable = true;

    # Ensure screenshot directory exists
    xdg.userDirs.extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
