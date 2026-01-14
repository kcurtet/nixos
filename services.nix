{pkgs, ...}: {
  # ============================================================================
  # File Synchronization
  # ============================================================================
  services.syncthing = {
    enable = true;
    user = "kx";
    dataDir = "/home/kx/syncthing";
  };

  # ============================================================================
  # VPN & Networking
  # ============================================================================
  services.tailscale = {
    enable = true;
    extraUpFlags = ["--ssh"];
  };

  # ============================================================================
  # Privacy & Anonymity
  # ============================================================================
  services.tor = {
    enable = true;
    enableGeoIP = false;
  };

  # ============================================================================
  # Virtualization
  # ============================================================================
  virtualisation.docker = {
    enable = true;
    extraPackages = with pkgs; [
      lazydocker
      dive
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    cloud-utils
  ];

  users.users.kx.extraGroups = ["libvirtd"];
}
