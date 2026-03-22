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
      font-family = "JetBrainsMono Nerd Font";
      window-padding-x = 10;
      window-padding-y = 10;
      background-opacity = 0.95;
      unfocused-split-opacity = 0.85;
      cursor-style = "block";
      cursor-style-blink = true;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      keybind = [
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+l=goto_split:right"
        "ctrl+alt+j=goto_split:bottom"
        "ctrl+alt+k=goto_split:top"
        "ctrl+shift+enter=new_split:right"
        "ctrl+shift+backslash=new_split:down"
        "alt+backspace=text:\x1b\x7f"
        "shift+enter=text:\n"
      ];
    };
  };
}
