# ============================================================================
# Atuin Shell History Configuration
# ============================================================================
_:

{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      style = "compact";
      show_help = false;
      max_preview_height = 4;
    };
  };
}
