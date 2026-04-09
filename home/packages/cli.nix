# ============================================================================
# CLI Tools and Utilities
# ============================================================================
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # XDG utilities
    xdg-terminal-exec

    # Markdown
    glow
    treemd

    # File managers and tree viewers
    eza
    tree

    # Archive tools
    p7zip
    unzip
    zip

    # System utilities
    btop
    dust
    iftop
    lm_sensors
    lsof
    procs
    socat

    # Terminal utilities
    fd
    jq
    ripgrep
    tldr
    trash-cli
    wl-clipboard

    # Network tools
    doggo
    gping
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
    castero # podcast client

    # Browser integration
    libsecret # for cookie extraction in browsers

    # Browsers
    nyxt # Keyboard-driven Emacs/Vim-style browser

    # Benchmarking and analysis
    hyperfine
    tokei

    # Spell checking
    hunspell
    hunspellDicts.en_US
    hunspellDicts.es_ES

    # Added packages
    ast-grep
    google-cloud-sdk
    pandoc
    tesseract
  ];
}
