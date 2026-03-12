# ============================================================================
# Ghostty Terminal Configuration
# ============================================================================
{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Nord";
      font-size = 14;
      keybind = [
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+l=goto_split:right"
        "alt+backspace=text:\x1b\x7f"
        "shift+enter=text:\n"
      ];
    };
  };
}
