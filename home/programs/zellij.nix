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

    web_client {
      font "Iosevka Term" // default is "monospace" - deferring this decision to the browser/os
      cursor_blink true // default is false
      cursor_style "block" // possibilities: "block", "bar", "underline"
      cursor_inactive_style "outline" // possibilities: "outline", "block", "bar", "underline"
    }

    theme "nord"
    mouse_mode true
    copy_command "wl-copy"
    default_mode "locked"
    copy_clipboard "primary"
    scrollback_editor "$EDITOR"
    show_startup_tips false
  '';
}
