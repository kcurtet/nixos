# ============================================================================
# Tmux Configuration
# ============================================================================
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    extraConfig = ''
      set -g mouse on
      set -g history-limit 10000
      set -g default-terminal "screen-256color"
      set -g extended-keys on
    '';
    plugins = with pkgs.tmuxPlugins; [
      nord
    ];
  };
}
