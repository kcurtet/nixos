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

    tor = lib.mkEnableOption "Tor service";

    flatpak = lib.mkEnableOption "Flatpak support";

    openssh = lib.mkEnableOption "OpenSSH server";

    ollama = lib.mkEnableOption "Ollama local AI";
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

    services.tor = lib.mkIf cfg.tor {
      enable = true;
      enableGeoIP = false;
    };

    services.flatpak.enable = cfg.flatpak;
    services.openssh.enable = cfg.openssh;
    services.ollama.enable = cfg.ollama;

    # Servidor DNS local con dnsmasq
    services.dnsmasq = {
      enable = true;
      settings = {
        # Resolver *.localhost a 127.0.0.1
        address = [ "/.localhost/127.0.0.1" ];

        # DNS upstream (puedes cambiarlos por los que prefieras)
        server = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        # Solo escuchar en loopback
        listen-address = "127.0.0.1";
        bind-interfaces = true;

        # No leer /etc/hosts para evitar conflictos
        no-hosts = false;

        # Cache
        cache-size = 1000;
      };
    };

    # Decirle al sistema que use dnsmasq como DNS
    networking.nameservers = [ "127.0.0.1" ];

    # Si usas NetworkManager, que no gestione el DNS el solo
    networking.networkmanager.dns = "none";

    # Asegurarse de que resolv.conf apunta a dnsmasq
    environment.etc."resolv.conf".text = ''
      nameserver 127.0.0.1
    '';
  };
}
