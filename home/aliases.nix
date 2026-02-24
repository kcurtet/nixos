# ============================================================================
# Shell Aliases
# ============================================================================
{ ... }:

{
  home.shellAliases = {
    # Editor
    e = "nvim";

    # Git shortcuts
    g = "git";
    gs = "git status";
    gc = "git commit";
    wip = "git commit -am wip";

    # File listing (using exa/eza)
    ls = "exa";
    l = "exa -l";
    ll = "exa -la";
    tree = "exa -T";
    t = "exa -T";
    tl = "exa -T -L";

    # Navigation
    "..." = "cd ../..";
  };
}
