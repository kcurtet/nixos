# ============================================================================
# Zellij Terminal Multiplexer Configuration
# ============================================================================
# 
# Key changes from defaults:
#   - Ctrl+g → unbound (was locked mode toggle)
#   - Ctrl+s → locked mode toggle (was scroll mode)
#   - Alt+s  → scroll mode (rebound from Ctrl+s)
#
# URLs are clickable by default via zellij:link plugin
# ============================================================================
{ ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "nord";
      keybinds = {
        # Override global Ctrl+g binding (was SwitchToMode "Locked")
        shared_except = {
          _args = ["locked"];
          "ctrl g" = ["unbind"];
          "ctrl s" = ["SwitchToMode" "Locked"];
        };
        # Locked mode: Ctrl+s exits to normal
        locked = {
          "ctrl g" = ["unbind"];
          "ctrl s" = ["SwitchToMode" "Normal"];
        };
        # Scroll mode: Alt+s exits (since Ctrl+s is now locked mode)
        scroll = {
          "alt s" = ["SwitchToMode" "Normal"];
        };
      };
    };
  };
}
