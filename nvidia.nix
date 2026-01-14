{
  config,
  lib,
  ...
}: {
  # ============================================================================
  # NVIDIA Driver Configuration
  # ============================================================================
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required for proper functionality
    modesetting.enable = true;

    # Power management (experimental - can cause sleep/suspend issues)
    # Enable if experiencing graphical corruption or crashes after wake
    powerManagement.enable = false;
    powerManagement.finegrained = false; # Only works on Turing+ GPUs

    # Open source kernel module (not nouveau)
    # Limited to Turing+ architectures
    # See: https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Available from driver 515.43.04+
    open = false;

    # NVIDIA settings GUI
    nvidiaSettings = true;

    # Driver package selection
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ============================================================================
  # NVIDIA Prime Configuration
  # ============================================================================
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    # Update Bus IDs to match your system's PCI configuration
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # ============================================================================
  # System Specialisations
  # ============================================================================
  specialisation = {
    # On-the-go: Use GPU offloading for better battery life
    on-the-go.configuration = {
      system.nixos.tags = ["on-the-go"];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce false;
        prime.offload.enableOffloadCmd = lib.mkForce false;
        prime.sync.enable = lib.mkForce true;
      };
    };

    # Disable NVIDIA: Completely disable NVIDIA hardware
    disable-nvidia.configuration = {
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';

      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA USB Type-C UCSI devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';

      boot.blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
      ];
    };
  };
}
