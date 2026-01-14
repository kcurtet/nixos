{pkgs, ...}: {
  # ============================================================================
  # Gaming Configuration
  # ============================================================================
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    lutris

    (writeShellScriptBin "game-run" ''
      nvidia-offload gamemoderun steam-run $@
    '')
  ];
}
