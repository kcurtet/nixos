# ============================================================================
# Alacritty Terminal Configuration
# ============================================================================
{ pkgs, ... }:
let
  theme = import ../../lib/themes.nix;
in
{
  programs.alacritty = {
    enable = true;

    settings = {
      # ── Window ──
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_padding = true;
        decorations = "Full";
        startup_mode = "Windowed";
        opacity = 0.95;
      };

      # ── Scrolling ──
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # ── Font ──
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
        size = 14;
      };

      # ── Colors — Nord ──
      colors = {
        primary = {
          background = theme.colors.n0;
          foreground = theme.colors.n4;
          dim_foreground = theme.colors.n3;
          bright_foreground = theme.colors.n6;
        };
        cursor = {
          text = theme.colors.n0;
          cursor = theme.colors.n8;
        };
        vi_mode_cursor = {
          text = theme.colors.n0;
          cursor = theme.colors.n8;
        };
        search = {
          matches = {
            foreground = theme.colors.n0;
            background = theme.colors.n8;
          };
          focused_match = {
            foreground = theme.colors.n0;
            background = theme.colors.n14;
          };
        };
        hints = {
          start = {
            foreground = theme.colors.n0;
            background = theme.colors.n13;
          };
          end = {
            foreground = theme.colors.n0;
            background = theme.colors.n1;
          };
        };
        line_indicator = {
          foreground = "None";
          background = "None";
        };
        footer_bar = {
          foreground = theme.colors.n0;
          background = theme.colors.n8;
        };
        selection = {
          text = "CellForeground";
          background = theme.colors.n2;
        };
        normal = {
          black = theme.colors.n1;
          red = theme.colors.n11;
          green = theme.colors.n14;
          yellow = theme.colors.n13;
          blue = theme.colors.n9;
          magenta = theme.colors.n15;
          cyan = theme.colors.n7;
          white = theme.colors.n5;
        };
        bright = {
          black = theme.colors.n3;
          red = theme.colors.n11;
          green = theme.colors.n14;
          yellow = theme.colors.n13;
          blue = theme.colors.n9;
          magenta = theme.colors.n15;
          cyan = theme.colors.n7;
          white = theme.colors.n6;
        };
        dim = {
          black = theme.colors.n1;
          red = theme.colors.n11;
          green = theme.colors.n14;
          yellow = theme.colors.n13;
          blue = theme.colors.n9;
          magenta = theme.colors.n15;
          cyan = theme.colors.n7;
          white = theme.colors.n4;
        };
      };

      # ── Bell ──
      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };

      # ── Selection ──
      selection = {
        save_to_clipboard = true;
      };

      # ── Cursor ──
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        vi_mode_style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
        unfocused_hollow = true;
      };

      # ── Mouse ──
      mouse = {
        hide_when_typing = true;
      };

      # ── Env ──
      env = {
        TERM = "xterm-256color";
      };

      # ── Shell ──
      shell = {
        program = "${pkgs.bash}/bin/bash";
        args = [ "--login" ];
      };

      # ── Keyboard ──
      keyboard = {
        bindings = [
          {
            key = "Plus";
            mods = "Control";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Control";
            action = "DecreaseFontSize";
          }
          {
            key = "Key0";
            mods = "Control";
            action = "ResetFontSize";
          }
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
        ];
      };
    };
  };
}
