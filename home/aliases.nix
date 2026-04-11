_: {
  home.shellAliases = {

    # Herramientas básicas
    g = "lazygit";
    y = "yazi";
    n = "nvim";
    k = "bat";
    o = "xdg-open";
    l = "eza -l --icons --group-directories-first";
    ll = "eza -la --icons --group-directories-first";
    t = "tree -L2 --dirsfirst --gitignore -h";

    # Git shortcuts
    gs = "git status";
    gc = "git checkout";
    gp = "git pull";
    gl = "git log --oneline --graph --decorate";
    gx = "git stash push -m wip";
    gsh = "git push";
    gcm = "git commit -m";
    wip = "git commit -am wip";

    # Television channels
    f = "tv files";
    s = "tv text";
    h = "tv tldr";
    m = "tv man-pages";
    r = "tv trash";
    u = "tv systemd-units";
    G = "tv git-log";
    D = "tv docker-containers";

    p = "pi -p";
    pi = "VISUAL=\$EDITOR pi";
  };
}
