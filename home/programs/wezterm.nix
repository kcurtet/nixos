# ============================================================================
# WezTerm Terminal Configuration
# Minimal — inspired by st: no tabs, no title bar, no chrome
# ============================================================================
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.wezterm-config;
in
{
  options.programs.wezterm-config = {
    enable = lib.mkEnableOption "WezTerm terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;

      extraConfig = ''
        local wezterm = require("wezterm")

        return {
          -- Font
          font = wezterm.font("JetBrainsMono Nerd Font"),
          font_size = 14.0,

          -- Window: minimal, no chrome
          window_decorations = "NONE",
          window_padding = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4,
          },
          enable_scroll_bar = false,

          -- Tabs: hidden entirely
          enable_tab_bar = false,

          -- Nord color scheme
          colors = {
            foreground = "#d8dee9",
            background = "#2e3440",
            cursor_bg = "#d8dee9",
            cursor_border = "#d8dee9",
            cursor_fg = "#2e3440",
            selection_bg = "#434c5e",
            selection_fg = "#d8dee9",
            ansi = {
              "#3b4252", -- black
              "#bf616a", -- red
              "#a3be8c", -- green
              "#ebcb8b", -- yellow
              "#81a1c1", -- blue
              "#b48ead", -- magenta
              "#88c0d0", -- cyan
              "#e5e9f0", -- white
            },
            brights = {
              "#4c566a", -- bright black
              "#bf616a", -- bright red
              "#a3be8c", -- bright green
              "#ebcb8b", -- bright yellow
              "#81a1c1", -- bright blue
              "#b48ead", -- bright magenta
              "#8fbcbb", -- bright cyan
              "#eceff4", -- bright white
            },
          },

          -- Misc
          audible_bell = "Disabled",
          default_cursor_style = "BlinkingBlock",
          cursor_blink_rate = 500,
          cursor_blink_ease_in = "Constant",
          cursor_blink_ease_out = "Constant",
          check_for_updates = false,
          warn_about_missing_glyphs = false,
        }
      '';
    };
  };
}
