# ============================================================================
# NVIDIA Specialisations
# Provides boot profiles for different GPU configurations
# ============================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.nvidiaConfig;
in
{
  config = lib.mkIf (cfg.enable && cfg.prime.enable) {
    specialisation = {
      # On-the-go: Use GPU sync for better performance
      on-the-go.configuration = {
        system.nixos.tags = ["on-the-go"];
        hardware.nvidia = {
          prime.offload.enable = lib.mkForce false;
          prime.offload.enableOffloadCmd = lib.mkForce false;
          prime.sync.enable = lib.mkForce true;
        };
      };

      # Disable Intel: Use only NVIDIA GPU
      disable-intel.configuration = {
        system.nixos.tags = ["disable-intel"];
        hardware.nvidia = {
          prime.offload.enable = lib.mkForce false;
          prime.offload.enableOffloadCmd = lib.mkForce false;
          prime.sync.enable = lib.mkForce false;
        };
        boot.extraModprobeConfig = ''
          blacklist i915
        '';
      };

      # Disable NVIDIA: Completely disable NVIDIA hardware for battery saving
      disable-nvidia.configuration = {
        system.nixos.tags = ["disable-nvidia"];
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
  };
}
