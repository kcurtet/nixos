# ============================================================================
# Home Manager Nord Theme Configuration
# ============================================================================
{ config, lib, ... }:

let
  # Import colors from lib
  colors = {
    n0 = "#2e3440";
    n1 = "#3b4252";
    n2 = "#434c5e";
    n3 = "#4c566a";
    n4 = "#d8dee9";
    n5 = "#e5e9f0";
    n6 = "#eceff4";
    n7 = "#8fbcbb";
    n8 = "#88c0d0";
    n9 = "#81a1c1";
    n10 = "#5e81ac";
    n11 = "#bf616a";
    n12 = "#d08770";
    n13 = "#ebcb8b";
    n14 = "#a3be8c";
    n15 = "#b48ead";
  };
in
{
  # GTK Theme
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Nordic";
    };
  };

  # LazyGit Theme
  programs.lazygit.settings.gui.theme = {
    activeBorderColor = [
      colors.n8
      "bold"
    ];
    inactiveBorderColor = [ colors.n3 ];
    searchingActiveBorderColor = [
      colors.n9
      "bold"
    ];
    selectedLineBgColor = [ colors.n1 ];
    selectedRangeBgColor = [ colors.n2 ];
    cherryPickedCommitBgColor = [ colors.n2 ];
    cherryPickedCommitFgColor = [ colors.n8 ];
    markedBaseCommitBgColor = [ colors.n15 ];
    markedBaseCommitFgColor = [ colors.n0 ];
    optionsTextColor = [ colors.n8 ];
    defaultFgColor = [ colors.n4 ];
    unstagedChangesColor = [ colors.n11 ];
    stagedChangesColor = [ colors.n14 ];
    untrackedChangesColor = [ colors.n13 ];
    conflictedChangesColor = [ colors.n11 ];
    remoteBranchColor = [ colors.n15 ];
    localBranchColor = [ colors.n14 ];
    tagColor = [ colors.n13 ];
    upstreamColor = [ colors.n10 ];
    reflogCommitColor = [ colors.n12 ];
    authorColor = [ colors.n7 ];
    commitHashColor = [ colors.n9 ];
  };

  # Bat Theme
  programs.bat.config.theme = "Nord";

  # Zellij Theme
  programs.zellij.settings.theme = "nord";

  # Tmux Theme (via plugin)
  programs.tmux.plugins = with config._module.args.pkgs.tmuxPlugins; [ nord ];

  # Ghostty Theme
  programs.ghostty.settings.theme = "Nord";
}
