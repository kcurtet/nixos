# ============================================================================
# Git Configuration
# ============================================================================
{ lib, pkgs, ... }:

# Delta: colorblind-friendly Nord theme
# ─────────────────────────────────────
# Design choices for daltonismo:
#   • Removed → blue tones (n9/n10) — visible in ALL colorblind types
#   • Added   → orange/amber tones (n12/n13) — max contrast vs blue
#   • Bold + background reinforce distinction beyond color alone
#   • Side-by-side for spatial separation of additions/removals
#   • Line numbers colored to match their type for extra cues

{
  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      # ── Base theme ──
      dark = true;
      true-color = "always";
      syntax-theme = "Nord";

      # ── Removed lines: blue tones ──
      minus-style = "normal #394b6e"; # dark blue bg
      minus-non-emph-style = "normal #394b6e";
      minus-emph-style = "bold #88c0d0 #2e4058"; # bright cyan fg on darker blue
      minus-empty-line-marker-style = "normal #394b6e";

      # ── Added lines: orange/amber tones ──
      plus-style = "syntax #4a3a2a"; # syntax-hl with warm dark bg
      plus-non-emph-style = "syntax #4a3a2a";
      plus-emph-style = "bold #ebcb8b #3a2e1e"; # bright yellow fg on warm bg
      plus-empty-line-marker-style = "syntax #4a3a2a";

      # ── Context lines ──
      zero-style = "syntax";

      # ── Line numbers ──
      line-numbers = true;
      line-numbers-minus-style = "#88c0d0 #2e3440"; # cyan on nord bg
      line-numbers-plus-style = "#d08770 #2e3440"; # orange on nord bg
      line-numbers-zero-style = "#4c566a #2e3440"; # muted on nord bg

      # ── File headers ──
      file-style = "bold #88c0d0";
      file-decoration-style = "#5e81ac ol";
      file-added-label = "added:";
      file-modified-label = "";
      file-removed-label = "removed:";
      file-renamed-label = "renamed:";

      # ── Hunk headers ──
      hunk-header-style = "file line-number syntax bold";
      hunk-header-decoration-style = "#5e81ac box";

      # ── Commit headers ──
      commit-style = "raw";

      # ── Navigation & layout ──
      navigate = true;
      side-by-side = true;

      # ── Merge conflicts ──
      merge-conflict-begin-symbol = "▽";
      merge-conflict-end-symbol = "△";
      merge-conflict-ours-diff-header-style = "#88c0d0 bold";
      merge-conflict-theirs-diff-header-style = "#d08770 bold";

      # ── Misc ──
      keep-plus-minus-markers = true;
      tabs = 4;
    };
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
