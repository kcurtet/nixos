# ============================================================================
# System Services Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  myLib = import ../../lib { inherit lib; };
  cfg = config.my.services;
in
{
  options.my.services = {
    syncthing = {
      enable = lib.mkEnableOption "Syncthing file synchronization";
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/${myLib.username}/syncthing";
        description = "Syncthing data directory";
      };
    };

    tailscale = {
      enable = lib.mkEnableOption "Tailscale VPN";
      ssh = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Tailscale SSH";
      };
    };

    tor = {
      enable = lib.mkEnableOption "Tor service";
      enableGeoIP = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Tor GeoIP";
      };
    };

    flatpak = {
      enable = lib.mkEnableOption "Flatpak support";
    };

    openssh = {
      enable = lib.mkEnableOption "OpenSSH server";
    };

    ollama = {
      enable = lib.mkEnableOption "Ollama local AI";
      port = lib.mkOption {
        type = lib.types.port;
        default = 11434;
        description = "Ollama server port";
      };
    };

    dnsmasq = {
      enable = lib.mkEnableOption "Local DNS via dnsmasq";

      upstreamServers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        description = "DNS upstream servers";
      };

      cacheSize = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "DNS cache size";
      };
    };
  };

  config = {
    services.syncthing = lib.mkIf cfg.syncthing.enable {
      enable = true;
      user = myLib.username;
      dataDir = cfg.syncthing.dataDir;
    };

    services.tailscale = lib.mkIf cfg.tailscale.enable {
      enable = true;
      extraUpFlags = lib.optional cfg.tailscale.ssh "--ssh";
    };

    services.tor = lib.mkIf cfg.tor.enable {
      enable = true;
      enableGeoIP = cfg.tor.enableGeoIP;
    };

    services.flatpak.enable = cfg.flatpak.enable;
    services.openssh.enable = cfg.openssh.enable;
    services.ollama = lib.mkIf cfg.ollama.enable {
      enable = true;
      host = "127.0.0.1";
      port = cfg.ollama.port;
    };

    # Local DNS server with dnsmasq
    services.dnsmasq = lib.mkIf cfg.dnsmasq.enable {
      enable = true;
      settings = {
        # Resolve *.localhost to 127.0.0.1
        address = [ "/.localhost/127.0.0.1" ];

        # DNS upstream servers
        server = cfg.dnsmasq.upstreamServers;

        # Only listen on loopback
        listen-address = "127.0.0.1";
        bind-interfaces = true;

        # Don't read /etc/hosts to avoid conflicts
        no-hosts = false;

        # Cache
        cache-size = cfg.dnsmasq.cacheSize;
      };
    };

    # Use dnsmasq as system DNS when enabled
    networking.nameservers = lib.mkIf cfg.dnsmasq.enable [ "127.0.0.1" ];
    networking.networkmanager.dns = lib.mkIf cfg.dnsmasq.enable "none";
    environment.etc."resolv.conf".text = lib.mkIf cfg.dnsmasq.enable ''
      nameserver 127.0.0.1
    '';
  };
}
