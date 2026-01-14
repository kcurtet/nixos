{
  config,
  pkgs,
  lib,
  ...
}: let
  # ============================================================================
  # LazyGit Nord Theme Configuration
  # Based on https://www.nordtheme.com/
  # ============================================================================
  lazygitNordTheme = {
    # Window borders
    activeBorderColor = ["#88c0d0" "bold"]; # nord8 - bright blue
    inactiveBorderColor = ["#4c566a"]; # nord3 - bright gray
    searchingActiveBorderColor = ["#81a1c1" "bold"]; # nord9 - dark blue

    # Selection colors
    selectedLineBgColor = ["#3b4252"]; # nord1 - lighter gray
    selectedRangeBgColor = ["#434c5e"]; # nord2

    # Commit colors
    cherryPickedCommitBgColor = ["#434c5e"];
    cherryPickedCommitFgColor = ["#88c0d0"];
    markedBaseCommitBgColor = ["#b48ead"]; # nord15 - purple
    markedBaseCommitFgColor = ["#2e3440"];

    # Text colors
    optionsTextColor = ["#88c0d0"]; # nord8
    defaultFgColor = ["#d8dee9"]; # nord4 - snow white

    # Git status colors
    unstagedChangesColor = ["#bf616a"]; # nord11 - red
    stagedChangesColor = ["#a3be8c"]; # nord14 - green
    untrackedChangesColor = ["#ebcb8b"]; # nord13 - yellow
    conflictedChangesColor = ["#bf616a"]; # nord11 - red

    # Branch and tag colors
    remoteBranchColor = ["#b48ead"]; # nord15 - purple
    localBranchColor = ["#a3be8c"]; # nord14 - green
    tagColor = ["#ebcb8b"]; # nord13 - yellow
    upstreamColor = ["#5e81ac"]; # nord10 - dark blue

    # Commit metadata colors
    reflogCommitColor = ["#d08770"]; # nord12 - orange
    authorColor = ["#8fbcbb"]; # nord7 - cyan
    commitHashColor = ["#81a1c1"]; # nord9 - blue
  };
in {
  # ============================================================================
  # Desktop Environment
  # ============================================================================
  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      {package = appindicator;}
      {package = caffeine;}
      {
        id = "user-theme@gnome-shell-extensions.gcampax.github.com";
        package = pkgs.gnome-shell-extensions;
      }
      {package = gamemode-shell-extension;}
    ];
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
  };

  # ============================================================================
  # Terminal Programs
  # ============================================================================
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Nord";
      font-size = 14;
      keybind = [
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+l=goto_split:right"
      ];
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "nord";
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      nord
    ];
  };

  # ============================================================================
  # Shell Configuration
  # ============================================================================
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.autojump.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ============================================================================
  # Development Tools
  # ============================================================================
  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Kevin Curtet";
      user.email = "kcurtet@gmail.com";
      user.signingKey = "kcurtet@gmail.com";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = lazygitNordTheme;
    };
  };

  # ============================================================================
  # Services
  # ============================================================================
  services.tailscale-systray.enable = true;

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  home.shellAliases = {
    # Editor
    e = "nvim";

    # Git shortcuts
    g = "git";
    gs = "git status";
    gc = "git commit";
    wip = "git commit -am wip";

    # File listing (using exa/eza)
    ls = "exa";
    l = "exa -l";
    ll = "exa -la";
    tree = "exa -T";
    t = "exa -T";
    tl = "exa -T -L";

    # Navigation
    "..." = "cd ../..";
  };

  # ============================================================================
  # System Packages
  # ============================================================================
  home.packages = with pkgs; [
    # NixOS rebuild shortcuts
    (writeShellScriptBin "nswitch" ''
      sudo nixos-rebuild switch --flake /home/kx/.config/nixos
    '')
    (writeShellScriptBin "nboot" ''
      sudo nixos-rebuild boot --flake /home/kx/.config/nixos
    '')

    hmcl
    mgba

    # Network tools
    netcat-openbsd
    lynx
    tor-browser

    # Desktop utilities
    opencode
    gnome-tweaks

    # Terminal emulators
    ghostty
    kitty

    # Terminal utilities
    eza
    ripgrep
    fd
    btop
    p7zip

    # Browsers
    brave
    librewolf

    # Editors
    neovim
    emacs
    vscode-fhs
    code-cursor-fhs
    obsidian
    obsidian-export

    # Communication
    telegram-desktop
    discord
    discordo

    # Media
    spotifywm

    # Version control
    git

    # Tools
    hcloud

    # Nix development tools
    nil
    nixd
    alejandra

    # JavaScript/TypeScript development
    nodejs
    pnpm
    typescript
    typescript-language-server
    prettier
    eslint

    # Python development
    python3
    pylint
    black

    # Lua development
    lua
    luaPackages.fennel
    stylua
    lua-language-server
    fennel-ls
  ];

  # ============================================================================
  # Home Manager State
  # ============================================================================
  home.stateVersion = "26.05";
}
