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
    delta.enable = true;
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      user.name = "Kevin Curtet";
      user.email = "kcurtet@gmail.com";
    };
  };
}
