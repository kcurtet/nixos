# ============================================================================
# NVIDIA Graphics Configuration Module
# ============================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.nvidiaConfig;
in
{
  options.hardware.nvidiaConfig = {
    enable = lib.mkEnableOption "NVIDIA graphics configuration";

    prime = {
      enable = lib.mkEnableOption "NVIDIA Prime hybrid graphics (Intel + NVIDIA)";

      intelBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:0:2:0";
        example = "PCI:0:2:0";
        description = "PCI bus ID for Intel GPU";
      };

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
        example = "PCI:1:0:0";
        description = "PCI bus ID for NVIDIA GPU";
      };
    };

    open = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use open-source NVIDIA kernel module (Turing+ GPUs only)";
    };

    powerManagement = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA power management (experimental)";
    };

    nvidiaSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install NVIDIA settings GUI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = cfg.powerManagement;
      powerManagement.finegrained = false;
      open = cfg.open;
      nvidiaSettings = cfg.nvidiaSettings;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    } // lib.optionalAttrs cfg.prime.enable {
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
      };
    };

    # Add NVIDIA kernel module to extraModulePackages
    boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.stable ];
  };
}
