# ============================================================================
# Ghostty Terminal Configuration
# ============================================================================
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Nord";
      font-size = 14;
      keybind = [
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+l=goto_split:right"
      ];
    };
  };
}
