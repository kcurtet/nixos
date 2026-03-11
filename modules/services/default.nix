# ============================================================================
# System Services Configuration Module
# ============================================================================
{ config, lib, pkgs, ... }:

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
  };
}
