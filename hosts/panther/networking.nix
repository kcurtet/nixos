# ============================================================================
# Panther Network Configuration
# ============================================================================
_:

{
  networking.hostName = "panther";
  networking.networkmanager.enable = true;

  networking.extraHosts = ''
    127.0.0.1 arr.local
    127.0.0.1 jellyfin.arr.local
    127.0.0.1 sonarr.arr.local
    127.0.0.1 radarr.arr.local
    127.0.0.1 bazarr.arr.local
    127.0.0.1 prowlarr.arr.local
    127.0.0.1 jackett.arr.local
    127.0.0.1 qbittorrent.arr.local
    127.0.0.1 sabnzbd.arr.local
  '';

  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # Firewall
  networking.firewall.enable = true;
}
