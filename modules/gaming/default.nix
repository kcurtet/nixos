# ============================================================================
# Gaming Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gaming;
in
{
  options.gaming = {
    enable = lib.mkEnableOption "gaming configuration (Steam, GameMode, etc.)";

    steam = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Steam";
    };

    gamemode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GameMode for performance optimization";
    };

    gamescope = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gamescope compositor";
    };

    wine = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wine for Windows games";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional gaming packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = cfg.steam;
      package = pkgs.steam.override {
        extraLibraries =
          p: with p; [
            libxcursor
            libxi
            libxinerama
            libxscrnsaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
      gamescopeSession = {
        enable = true;
        env = {
          WLR_RENDERER = "vulkan";
          DXVK_HDR = "1";
          ENABLE_GAMESCOPE_WSI = "1";
          WINE_FULLSCREEN_FSR = "1";
        };
        args = [
          "--expose-wayland"
          "-e"
          "--steam"
          "--force-composition"
          "--adaptive-sync"
          "--hdr-enabled"
        ];
      };
    };
    programs.gamemode = {
      enable = cfg.gamemode;
      settings = {
        general = {
          renice = 10;
        };
        cpu = {
          park_cores = "no";
          pin_cores = "yes";
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
      };
    };

    # mangohud - package installed below, no programs.mangohud option in this version
    # programs.mangohud.enable = true;

    programs.gamescope = lib.mkIf cfg.gamescope {
      enable = true;
      capSysNice = true;
    };

    # Fix bwrap "Unexpected capabilities but not setuid" error in gamescope
    security.wrappers.bwrap = {
      source = "${pkgs.bubblewrap}/bin/bwrap";
      capabilities = "cap_sys_admin,cap_sys_ptrace+ep";
    };

    environment.systemPackages =
      with pkgs;
      [
        aseprite
        chess-tui
        chessdb
        protonup-qt # Gestor de versiones de Proton
        protontricks # Instalar dependencias Windows en juegos Steam
      ]
      ++ lib.optional cfg.steam lutris
      ++ lib.optional cfg.wine wine64Packages.waylandFull
      ++ lib.optional cfg.wine winetricks
      ++ lib.optional (cfg.steam && cfg.gamemode) (
        writeShellScriptBin "game-run" ''
          nvidia-offload gamemoderun steam-run $@
        ''
      )
      ++ cfg.extraPackages;
  };
}
