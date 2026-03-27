# ============================================================================
# Git Configuration
# ============================================================================
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git-filter-repo
  ];
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
