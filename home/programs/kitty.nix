# ============================================================================
# Kitty Terminal Configuration
# ============================================================================
{ ... }:
{
  programs.kitty = {
    enable = true;
    theme = "Nord";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
    settings = {
      # Performance
      "repaint_delay" = 10;
      "input_delay" = 3;
      "sync_to_monitor" = "yes";

      # Window
      "remember_window_size" = "yes";
      "initial_window_width" = "640";
      "initial_window_height" = "400";
      "window_padding_width" = 10;
      "single_window_padding_width" = -1;
      "window_border_width" = "1pt";

      # Tabs
      "tab_bar_edge" = "bottom";
      "tab_bar_style" = "powerline";
      "tab_powerline_style" = "slanted";

      # Bell
      "enable_audio_bell" = "no";
      "visual_bell_duration" = "0.0";
      "window_alert_on_bell" = "once";
      "bell_on_tab" = "yes";

      # Cursor
      "cursor_shape" = "block";
      "cursor_blink_interval" = "0.5";
      "cursor_stop_blinking_after" = "15.0";

      # Scrollback
      "scrollback_lines" = 10000;
      "scrollback_pager" = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";

      # Mouse
      "copy_on_select" = "clipboard";
      "strip_trailing_spaces" = "smart";
      "open_url_with" = "default";
      "url_prefixes" = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";

      # Terminal
      "term" = "xterm-256color";

      # Background opacity (for compositor)
      "background_opacity" = "0.95";
    };

    keybindings = {
      # Splits
      "ctrl+shift+enter" = "launch --location=vsplit --cwd=current";
      "ctrl+shift+backslash" = "launch --location=hsplit --cwd=current";

      # Navigation
      "ctrl+alt+left" = "neighboring_window left";
      "ctrl+alt+right" = "neighboring_window right";
      "ctrl+alt+up" = "neighboring_window up";
      "ctrl+alt+down" = "neighboring_window down";

      # Tabs
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+," = "move_tab_backward";

      # Font size
      "ctrl+shift+equal" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";

      # Misc
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "paste_from_selection";
      "ctrl+shift+f" = "launch --type=overlay --stdin-source=@screen_scrollback fzf --no-sort --no-mouse --exact -i tac +s -m --ansi --tiebreak=begin --bind=shift-tab:up,tab:down --cycle q";
    };
  };
}
