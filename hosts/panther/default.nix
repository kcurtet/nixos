# ============================================================================
# Panther Host Configuration
# Main laptop with Intel + NVIDIA hybrid graphics
# ============================================================================
{ inputs, pkgs, lib, ... }:

let
  scripts = import ../../scripts { inherit pkgs; flakePath = "/home/kx/.config/nixos"; };
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
  # Host Metadata
  # ============================================================================
  my.username = "kx";

  # ============================================================================
  # Nix Configuration
  # ============================================================================
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

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
        emoji = ["Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font"];
        sansSerif = ["Adwaita Sans"];
        serif = ["Adwaita Serif"];
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
      ids = ["*"];
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
    extraGroups = ["wheel" "networkmanager" "docker"];
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
      extraPackages = with pkgs; [ lazydocker dive ];
    };
    libvirtd.enable = true;
  };

  # ============================================================================
  # Services
  # ============================================================================
  my.services = {
    syncthing.enable = true;
    tailscale.enable = true;
    tor.enable = true;
    flatpak.enable = true;
    ollama.enable = true;
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
  environment.systemPackages = with pkgs; [
    wl-clipboard
    proton-vpn-cli
    neovim
    wine-staging
    winetricks
  ] ++ builtins.attrValues scripts;

  # ============================================================================
  # Programs
  # ============================================================================
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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
  # System State
  # ============================================================================
  system.stateVersion = "26.05";
}
