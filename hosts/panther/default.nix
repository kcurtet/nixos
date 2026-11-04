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
  scripts = import ../../scripts { inherit pkgs; };
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
    ../../modules/desktop/sway
    ../../modules/desktop/kde
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
    max-jobs = "auto"; # Usar todos los cores disponibles
    cores = 0; # 0 = ilimitado
    sandbox = true; # sandboxing más rápido que chroot

    # Optimizar store automáticamente
    auto-optimise-store = true;

    # Evitar GC interrumpiendo builds
    min-free = 5 * 1024 * 1024 * 1024; # 5GB
    max-free = 10 * 1024 * 1024 * 1024; # 10GB

    # Mantener derivaciones para evitar rebuilds
    keep-outputs = true;
    keep-derivations = true;
  };
  nixpkgs.config.allowUnfree = true;

  # Garbage Collection automático para evitar que el store crezca sin control
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d"; # Borrar generaciones >30 días
  };

  # Nix daemon service - use batch scheduling for better build performance
  systemd.services.nix-daemon.serviceConfig = {
    CPUSchedulingPolicy = lib.mkForce "batch";
    IOSchedulingClass = lib.mkForce "best-effort";
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
  # Desktop Environment - Sway + KDE
  # ============================================================================
  desktop.sway.enable = true;
  desktop.kde.enable = true;

  # SDDM display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.enable = true;
  services.xserver.xkb.layout = "es";
  services.xserver.xkb.variant = "cat";
  services.gnome.gnome-keyring.enable = true;

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
  # Los usuarios siguen siendo mutables: la contraseña se cambia con `passwd`
  # y NixOS no la sobrescribe en cada rebuild.
  users.mutableUsers = true;

  users.users.kx = {
    isNormalUser = true;
    shell = pkgs.bash;
    # Contraseña temporal solo para el primer arranque tras instalar.
    # Se cambia con `passwd` nada más entrar; no es la contraseña real.
    initialPassword = "p0wn3d";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "input"
    ];
  };

  # Portátil personal de un solo usuario: sudo sin contraseña por comodidad.
  # En un servidor o en equipos de otros usuarios iría a `true`.
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
    tor = {
      enable = true;
      enableGeoIP = false;
    };
    flatpak.enable = false;
    openssh.enable = false;
    ollama = {
      enable = true;
      port = 11434;
    };
    dnsmasq = {
      enable = true;
      upstreamServers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      cacheSize = 1000;
    };
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
      psmisc
      proton-vpn-cli
      wine-staging
      winetricks
      nixfmt-tree
      ydotool
    ]
    ++ builtins.attrValues scripts;

  # ============================================================================
  # Programs
  # ============================================================================
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
    backupFileExtension = "hm-backup";
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

  # ============================================================================
  # NPM Token Setup (from SOPS secret)
  # ============================================================================
  systemd.services."setup-npm-token-for-kx" = {
    description = "Generate .npmrc with SOPS-managed token";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "kx";
      ExecStart = pkgs.writeShellScript "setup-npm-token" ''
        if [ -f /run/secrets/npm-token ]; then
          TOKEN=$(cat /run/secrets/npm-token)
          echo "//registry.npmjs.org/:_authToken=$TOKEN" > /home/kx/.npmrc
          echo "prefix=/home/kx/.npm-global" >> /home/kx/.npmrc
          chmod 600 /home/kx/.npmrc
        fi
      '';
      RemainAfterExit = true;
    };
  };
}
