# ============================================================================
# Git Configuration
# ============================================================================
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      user.name = "Kevin Curtet";
      user.email = "kcurtet@gmail.com";
    };
  };
}
