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
    programs.steam.enable = cfg.steam;
    programs.gamemode.enable = cfg.gamemode;

    programs.gamescope = lib.mkIf cfg.gamescope {
      enable = true;
      capSysNice = true;
    };

    environment.systemPackages =
      with pkgs;
      [ mangohud ]
      ++ lib.optional cfg.steam lutris
      ++ lib.optional cfg.wine wineWow64Packages.waylandFull
      ++ lib.optional cfg.wine winetricks
      ++ lib.optional (cfg.steam && cfg.gamemode) (
        writeShellScriptBin "game-run" ''
          nvidia-offload gamemoderun steam-run $@
        ''
      )
      ++ cfg.extraPackages;
  };
}
