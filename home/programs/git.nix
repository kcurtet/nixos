# ============================================================================
# Git Configuration
# ============================================================================
{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
