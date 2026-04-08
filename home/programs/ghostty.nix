# ============================================================================
# Ghostty Terminal Configuration
# ============================================================================
{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      language = "es";
      command = "${pkgs.bash}/bin/bash -l";
      theme = "Nord";
      font-size = 14;
      font-family = "JetBrainsMono Nerd Font";
      window-padding-x = 10;
      window-padding-y = 10;
      cursor-style = "block";
      cursor-style-blink = true;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
    };
  };
}
