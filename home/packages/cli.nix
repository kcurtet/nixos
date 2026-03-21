# ============================================================================
# CLI Tools and Utilities
# ============================================================================
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # File managers and tree viewers
    eza
    tree
    treemd
    yazi

    # Archive tools
    p7zip
    unzip
    zip

    # System utilities
    btop
    iftop
    lm_sensors
    lsof

    # Terminal utilities
    fd
    jq
    ripgrep
    trash-cli

    # Network tools
    lynx
    netcat-openbsd

    # Notifications
    notify-desktop

    # Version control
    gh
    git
    worktrunk

    # Nix tools
    nixd
    nixfmt-tree

    # Media tools
    ffmpeg
    timg
    yt-dlp

    # Browser integration
    libsecret # for cookie extraction in browsers

    # Browsers
    nyxt # Keyboard-driven Emacs/Vim-style browser

    # Kitty themes
    kitty-themes

    # Added packages
    ast-grep
    google-cloud-sdk
    tesseract
  ];
}
