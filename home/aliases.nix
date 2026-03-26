# ============================================================================
# Shell Aliases
# ============================================================================
_:

{
  home.shellAliases = {
    # Editores
    e = "nvim";
    v = "nvim";

    # Herramientas básicas
    k = "bat";
    o = "xdg-open";
    l = "eza -l --icons --group-directories-first";
    ll = "eza -la --icons --group-directories-first";
    g = "lazygit";
    y = "yazi";
    z = "zi"; # zoxide interactive

    # Git shortcuts
    gs = "git status";
    gc = "git commit";
    gcm = "git commit -m";
    wip = "git commit -am wip";
    gp = "git push";
    gl = "git log --oneline --graph --decorate";

    # Television channels
    f = "tv files";
    s = "tv text";
    r = "tv trash";
    p = "tv procs";
    m = "tv man-pages";
    u = "tv systemd-units";
    n = "tv env";
    G = "tv git-log";
    D = "tv docker-containers";

    # pi-coding-agent shortcuts
    haiku = "pi -p haiku --model";
    sonnet = "pi -p sonnet --model";
    opus = "pi -p claude-opus-4.6 --model";
    gpt = "pi -p gpt-5.4 --model";
    gpt-mini = "pi -p gpt-5.4-mini --model";
    grok = "pi -p --model grok-code-fast-1";
  };
}
