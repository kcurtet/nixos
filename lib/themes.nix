# ============================================================================
# Nord Theme Configuration
# Based on https://www.nordtheme.com/
# ============================================================================
{
  colors = {
    # Polar Night
    n0 = "#2e3440";
    n1 = "#3b4252";
    n2 = "#434c5e";
    n3 = "#4c566a";

    # Snow Storm
    n4 = "#d8dee9";
    n5 = "#e5e9f0";
    n6 = "#eceff4";

    # Frost
    n7 = "#8fbcbb"; # cyan
    n8 = "#88c0d0"; # bright cyan
    n9 = "#81a1c1"; # blue
    n10 = "#5e81ac"; # dark blue

    # Aurora
    n11 = "#bf616a"; # red
    n12 = "#d08770"; # orange
    n13 = "#ebcb8b"; # yellow
    n14 = "#a3be8c"; # green
    n15 = "#b48ead"; # purple
  };

  # GTK theme name
  gtk = "Nordic";
  gtkPackage = "nordic";

  # Cursor theme
  cursor = {
    name = "Nordzy-cursors";
    package = "nordzy-cursor-theme";
  };

  # LazyGit theme generator
  lazygit = colors: {
    # Window borders
    activeBorderColor = [
      colors.n8
      "bold"
    ];
    inactiveBorderColor = [ colors.n3 ];
    searchingActiveBorderColor = [
      colors.n9
      "bold"
    ];

    # Selection colors
    selectedLineBgColor = [ colors.n1 ];
    selectedRangeBgColor = [ colors.n2 ];

    # Commit colors
    cherryPickedCommitBgColor = [ colors.n2 ];
    cherryPickedCommitFgColor = [ colors.n8 ];
    markedBaseCommitBgColor = [ colors.n15 ];
    markedBaseCommitFgColor = [ colors.n0 ];

    # Text colors
    optionsTextColor = [ colors.n8 ];
    defaultFgColor = [ colors.n4 ];

    # Git status colors
    unstagedChangesColor = [ colors.n11 ];
    stagedChangesColor = [ colors.n14 ];
    untrackedChangesColor = [ colors.n13 ];
    conflictedChangesColor = [ colors.n11 ];

    # Branch and tag colors
    remoteBranchColor = [ colors.n15 ];
    localBranchColor = [ colors.n14 ];
    tagColor = [ colors.n13 ];
    upstreamColor = [ colors.n10 ];

    # Commit metadata colors
    reflogCommitColor = [ colors.n12 ];
    authorColor = [ colors.n7 ];
    commitHashColor = [ colors.n9 ];
  };
}
