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

  patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [ ./bwrap.patch ];
  });
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
            libxcb
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
        buildFHSEnv = (args: ((pkgs.buildFHSEnv.override {
          bubblewrap = patchedBwrap;
        }) (args // {
          extraBwrapArgs = (args.extraBwrapArgs or []) ++ [ "--cap-add ALL" ];
        })));
      };
      gamescopeSession = {
        enable = true;
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

    programs.gamescope = lib.mkIf cfg.gamescope {
      enable = true;
      capSysNice = true;
    };

    system.activationScripts.steamBwrapSymlink = let
      patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
        patches = (o.patches or []) ++ [ ./bwrap.patch ];
      });
    in {
      text = ''
        steam_bwrap="/home/kx/.local/share/Steam/ubuntu12_32/steam-runtime/usr/libexec/steam-runtime-tools-0/srt-bwrap"
        if [ -d "$(dirname "$steam_bwrap")" ]; then
          ln -sf "${patchedBwrap}/bin/bwrap" "$steam_bwrap"
        fi
      '';
      deps = [];
    };

    environment.systemPackages =
      with pkgs;
      [
        gamescope-wsi
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
