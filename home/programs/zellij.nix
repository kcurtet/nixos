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
    enableBashIntegration = true;

    settings = {
      theme = "nord";
      mouse_mode = true;
      copy_command = "wl-copy";
      default_mode = "locked";
      copy_clipboard = "primary";
      scrollback_editor = "\$EDITOR";
      show_startup_tips = false;

      keybinds = {
        locked._children = [
          { unbind._args = [ "Ctrl g" ]; }
          {
            bind = {
              _args = [ "Ctrl s" ];
              _children = [
                { SwitchToMode._args = [ "Normal" ]; }
              ];
            };
          }
        ];

        scroll._children = [
          {
            bind = {
              _args = [ "Alt s" ];
              _children = [
                { SwitchToMode._args = [ "Normal" ]; }
              ];
            };
          }
        ];

        shared_except._args = [ "locked" ];
        shared_except._children = [
          { unbind._args = [ "Ctrl g" ]; }
          {
            bind = {
              _args = [ "Ctrl s" ];
              _children = [
                { SwitchToMode._args = [ "Locked" ]; }
              ];
            };
          }
        ];
      };

      web_client = {
        font = "Iosevka Term";
        cursor_blink = true;
        cursor_style = "block";
        cursor_inactive_style = "outline";
      };
    };
  };
}
