# ============================================================================
# GUI Applications
# ============================================================================
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Desktop utilities
    gnome-tweaks

    # Terminal emulators
    ghostty

    # Browsers
    brave
    librewolf
    chromium

    # Communication
    telegram-desktop
    discord

    # Media
    spotifywm

    # Gaming
    hmcl
    mgba

    # Internet
    google-chrome

    # Privacy
    tor-browser

    # Note taking
    obsidian

    # Office
    libreoffice-fresh
  ];
}
