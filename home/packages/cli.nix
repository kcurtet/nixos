# ============================================================================
# CLI Tools and Utilities
# ============================================================================
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tree
    treemd
    libsecret # for cookie extraction in browsers
    yt-dlp
    ffmpeg
    # System utilities
    lsof
    iftop
    btop
    lm_sensors

    # Archive tools
    zip
    unzip
    p7zip

    # Terminal utilities
    trash-cli
    jq
    eza
    ripgrep
    fd

    # Network tools
    netcat-openbsd
    lynx

    # Notifications
    notify-desktop

    # Version control
    gh
    git

    # Nix tools
    nixd
    nixfmt
  ];
}
