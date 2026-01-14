{
  inputs,
  pkgs,
  ...
}: {
  # ============================================================================
  # Imports
  # ============================================================================
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    #./laptop.nix
    ./nvidia.nix
    ./gaming.nix
    ./services.nix
  ];

  # ============================================================================
  # Nix Configuration
  # ============================================================================
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      neovim = inputs.nixvim.packages.${pkgs.stdenv.system}.default;
    })
  ];

  # ============================================================================
  # Boot Configuration
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ============================================================================
  # Localization
  # ============================================================================
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # ============================================================================
  # Fonts
  # ============================================================================
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.dejavu_fonts
      pkgs.nerd-fonts.monofur
      pkgs.noto-fonts-color-emoji
      pkgs.nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font"];
        sansSerif = ["Adwaita Sans"];
        serif = ["Adwaita Serif"];
      };
    };
  };

  # ============================================================================
  # Desktop Environment
  # ============================================================================
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.xserver.xkb.layout = "es";
  services.xserver.xkb.variant = "cat";

  # ============================================================================
  # Keyboard Configuration
  # ============================================================================
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings.main = {
        capslock = "overload(control, esc)";
        esc = "capslock";
      };
    };
  };

  # ============================================================================
  # Audio
  # ============================================================================
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ============================================================================
  # User Management
  # ============================================================================
  users.users.kx = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    initialPassword = "secret";
  };

  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # Home Manager
  # ============================================================================
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.kx = ./home.nix;
  };

  # ============================================================================
  # System Packages
  # ============================================================================
  environment.systemPackages = with pkgs; [
    neovim
    lm_sensors
    zip
    unzip
    p7zip
    wine-staging
    winetricks
  ];

  # ============================================================================
  # Programs
  # ============================================================================
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # ============================================================================
  # Services
  # ============================================================================
  services.openssh.enable = true;

  # ============================================================================
  # System State
  # ============================================================================
  # DO NOT change this value after initial installation unless you understand
  # the implications. See: https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05";
}
