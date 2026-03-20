# ============================================================================
# Shell Aliases
# ============================================================================
{ ... }:

{
  home.shellAliases = {
    # Editor
    e = "nvim";
    v = "nvim";

    z = "zellij";

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
    t = "exa -T";
    L = "exa -T -L";

    # Navigation
    c = "jump";

    # pi-coding-agent shortcuts
    haiku = "pi -p haiku --model";
    sonnet = "pi -p sonnet --model";
    opus = "pi -p claude-opus-4.6 --model";
    gpt = "pi -p gpt-5.4 --model";
    gpt-mini = "pi -p gpt-5.4-mini --model";
    grok = "pi -p --model grok-code-fast-1";
  };
}
