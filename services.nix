{pkgs, ...}: {
  services.syncthing = {
    enable = true;
    user = "kx";
    dataDir = "/home/kx/syncthing";
  };

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = ["--ssh"];

  services.tor = {
    enable = true;
    enableGeoIP = false;
  };

  virtualisation.docker = {
    enable = true;
    extraPackages = with pkgs; [lazydocker dive];
  };
}
