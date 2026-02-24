# ============================================================================
# Virtualization Configuration Module
# ============================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.virtualization;
in
{
  options.virtualization = {
    docker = {
      enable = lib.mkEnableOption "Docker container runtime";
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional Docker-related packages";
      };
    };

    libvirtd = {
      enable = lib.mkEnableOption "libvirtd for KVM/QEMU virtualization";
      qemuPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.qemu_kvm;
        description = "QEMU package to use";
      };
    };
  };

  config = {
    virtualisation.docker = lib.mkIf cfg.docker.enable {
      enable = true;
      extraPackages = cfg.docker.extraPackages;
    };

    virtualisation.libvirtd = lib.mkIf cfg.libvirtd.enable {
      enable = true;
      qemu = {
        package = cfg.libvirtd.qemuPackage;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    environment.systemPackages = lib.mkIf cfg.libvirtd.enable (with pkgs; [
      virt-manager
      virt-viewer
      cloud-utils
    ]);

    # Add user to libvirtd group
    users.users.${config.my.username or "kx"}.extraGroups =
      lib.optional cfg.libvirtd.enable "libvirtd";
  };
}
