# ============================================================================
# Panther Host Configuration
# Main laptop with Intel + NVIDIA hybrid graphics
# ============================================================================
{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  scripts = import ../../scripts {
    inherit pkgs;
    flakePath = "/home/kx/system/nixos-config";
  };
in
{
  imports = [
    # Hardware
    ./hardware.nix
    ./networking.nix

    # Modules
    ../../modules/nvidia
    ../../modules/nvidia/specialisations.nix
    ../../modules/gaming
    ../../modules/virtualization
    ../../modules/desktop/gnome
    ../../modules/services
    ../../modules/laptop
  ];

  # ============================================================================
  # Nix Configuration
  # ============================================================================
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "@wheel" ];
    max-jobs = 4; # Máximo 2 compilaciones en paralelo
    cores = 4; # Hasta 4 núcleos por compilación
  };
  nixpkgs.config.allowUnfree = true;

  # Nix daemon service - use idle scheduling to reduce system impact
  systemd.services.nix-daemon.serviceConfig = {
    CPUSchedulingPolicy = lib.mkForce "idle";
    IOSchedulingClass = lib.mkForce "idle";
  };

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
    packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.monofur
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Adwaita Sans" ];
        serif = [ "Adwaita Serif" ];
      };
    };
  };

  # ============================================================================
  # Desktop Environment - GNOME
  # ============================================================================
  desktop.gnome = {
    enable = true;
    xkb.layout = "es";
    xkb.variant = "cat";
  };

  # ============================================================================
  # Audio
  # ============================================================================
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ============================================================================
  # Keyboard Configuration (keyd)
  # ============================================================================
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
        esc = "capslock";
      };
    };
  };

  # ============================================================================
  # User Management
  # ============================================================================
  users.users.kx = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    initialPassword = "secret";
  };

  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # Hardware - NVIDIA
  # ============================================================================
  hardware.nvidiaConfig = {
    enable = true;
    prime = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ============================================================================
  # Gaming
  # ============================================================================
  gaming.enable = true;

  # ============================================================================
  # Virtualization
  # ============================================================================
  virtualization = {
    docker = {
      enable = true;
      extraPackages = with pkgs; [
        lazydocker
        dive
      ];
    };
    libvirtd.enable = true;
  };

  # ============================================================================
  # Services
  # ============================================================================
  my.services = {
    syncthing.enable = true;
    tailscale.enable = true;
    tor = true;
    flatpak = false;
    ollama = true;
  };

  # ============================================================================
  # Laptop Power Management (disabled by default)
  # ============================================================================
  laptop.powerManagement.enable = false;

  # ============================================================================
  # Overlays
  # ============================================================================
  nixpkgs.overlays = import ../../overlays { inherit inputs pkgs; };

  # ============================================================================
  # System Packages
  # ============================================================================
  environment.systemPackages =
    with pkgs;
    [
      wl-clipboard
      proton-vpn-cli
      neovim
      wine-staging
      winetricks
    ]
    ++ builtins.attrValues scripts;

  # ============================================================================
  # Programs
  # ============================================================================
  programs.fish.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    glibc
    zlib
    # add more if needed, e.g. libX11, libXcursor, libXrandr, alsa-lib, pulseaudio, etc.
  ];

  # ============================================================================
  # Environment Variables
  # ============================================================================
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ============================================================================
  # Home Manager
  # ============================================================================
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.kx = import ../../home;
  };

  # ============================================================================
  # SOPS Secrets Management
  # ============================================================================
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/kx/.config/sops/age/keys.txt";

  sops.secrets = {
    zai_api_key = {
      owner = "kx";
      mode = "0600";
    };
    brave_api_key = {
      owner = "kx";
      mode = "0600";
    };
  };

  # ============================================================================
  # System State
  # ============================================================================
  system.stateVersion = "26.05";
}
