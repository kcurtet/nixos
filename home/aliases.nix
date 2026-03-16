# ============================================================================
# Shell Aliases
# ============================================================================
{ ... }:

{
  home.shellAliases = {
    # Editor
    e = "nvim";
    v = "nvim";

    # Git shortcuts
    g = "git";
    gs = "git status";
    gc = "git commit";
    gcm = "git commit -m";
    wip = "git commit -am wip";
    gp = "git push";
    gl = "git log --oneline --graph --decorate";

    # File listing (using exa/eza)
    ls = "exa";
    l = "exa -l";
    ll = "exa -la";
    la = "exa -a";
    tree = "exa -T";
    t = "exa -T";
    tl = "exa -T -L";

    # Navigation
    c = "jump";
  };
}
