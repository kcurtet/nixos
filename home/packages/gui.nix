# ============================================================================
# GUI Applications
# ============================================================================
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Desktop utilities
    gnome-tweaks

    # Terminal emulators
    ghostty
    kitty

    # Browsers
    brave
    librewolf

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

    # Finance
    pkgs.custom.kraken-desktop
  ];
}
