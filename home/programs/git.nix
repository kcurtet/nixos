# ============================================================================
# Git Configuration
# ============================================================================
{ lib, ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
