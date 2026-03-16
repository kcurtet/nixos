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
  programs.zellij.enable = true;
  
  xdg.configFile."zellij/config.kdl".text = ''
    keybinds {
        locked {
            unbind "Ctrl g"
            bind "Ctrl s" { SwitchToMode "Normal"; }
        }
        scroll {
            bind "Alt s" { SwitchToMode "Normal"; }
        }
        shared_except "locked" {
            unbind "Ctrl g"
            bind "Ctrl s" { SwitchToMode "Locked"; }
        }
    }
    theme "nord"
  '';
}
