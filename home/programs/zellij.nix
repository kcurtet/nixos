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
    exitShellOnExit = true;
    layouts = {
      dev = {
        layout = {
          _children = [
            {
              default_tab_template = {
                _children = [
                  {
                    pane = {
                      size = 1;
                      borderless = true;
                      plugin = {
                        location = "zellij:tab-bar";
                      };
                    };
                  }
                  { "children" = { }; }
                  {
                    pane = {
                      size = 2;
                      borderless = true;
                      plugin = {
                        location = "zellij:status-bar";
                      };
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Project";
                  focus = true;
                };
                _children = [
                  {
                    pane = {
                      command = "nvim";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Git";
                };
                _children = [
                  {
                    pane = {
                      command = "lazygit";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Files";
                };
                _children = [
                  {
                    pane = {
                      command = "yazi";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Shell";
                };
                _children = [
                  {
                    pane = {
                      command = "bash";
                    };
                  }
                ];
              };
            }
          ];
        };
      };
    };
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
        font = "monospace"; # "Iosevka Term";
        cursor_blink = true;
        cursor_style = "block";
        cursor_inactive_style = "outline";
      };
    };
  };
}
