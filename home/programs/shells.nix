# ============================================================================
# Fish & Zsh Shell Configuration
# ============================================================================
{ lib, pkgs, ... }:

{
  # Scripts que necesitan actuar sobre la selección de tv
  home.packages = [
    (pkgs.writeShellScriptBin "clip" ''
      file="$1"
      if [ -z "$file" ]; then
        file=$(${pkgs.television}/bin/tv)
        [ -z "$file" ] && exit 0
      fi
      cat "$file" | ${pkgs.wl-clipboard}/bin/wl-copy
      echo "Copied $file to clipboard"
    '')
    (pkgs.writeShellScriptBin "E" ''
      selected=$(${pkgs.television}/bin/tv)
      if [ -n "$selected" ]; then
        nvim "$selected"
      fi
    '')
    (pkgs.writeShellScriptBin "b" ''
      branch=$(${pkgs.television}/bin/tv git-branch)
      if [ -n "$branch" ]; then
        git checkout "$branch"
      fi
    '')
    (pkgs.writeShellScriptBin "S" ''
      host=$(${pkgs.television}/bin/tv ssh-hosts)
      if [ -n "$host" ]; then
        ssh "$host"
      fi
    '')
    (pkgs.writeShellScriptBin "cheat" ''
      ${pkgs.gum}/bin/gum style \
        --border rounded --border-foreground 4 --padding "0 2" \
        --bold "⌨  Cheat Sheet"

      printf "\n"
      ${pkgs.gum}/bin/gum style --foreground 4 --bold "  Editores & Herramientas"
      cat <<'EOF'
        e / v   nvim                    k       bat
        o       xdg-open                l       eza -la --icons
        g       lazygit                 y       yazi
        z       autojump (cd rápido)
      EOF

      printf "\n"
      ${pkgs.gum}/bin/gum style --foreground 5 --bold "  Television (fuzzy finder)"
      cat <<'EOF'
        f       archivos                s       buscar texto
        h       historial               d       cd a directorio
        w       cd a worktree           b       checkout branch
        m       man pages               p       procesos
        r       trash                   u       systemd units
        n       variables de entorno    S       ssh a host
        G       git log                 D       docker containers
        E       nvim + picker
      EOF

      printf "\n"
      ${pkgs.gum}/bin/gum style --foreground 3 --bold "  Clipboard & Archivos"
      cat <<'EOF'
        clip [archivo]   copiar al clipboard (sin arg → tv picker)
      EOF

      printf "\n"
      ${pkgs.gum}/bin/gum style --foreground 2 --bold "  Git"
      cat <<'EOF'
        gs      git status              gc      git commit
        gcm     git commit -m           gp      git push
        gl      git log --oneline       wip     git commit -am wip
      EOF

      printf "\n"
      ${pkgs.gum}/bin/gum style --foreground 6 --bold "  Pi Agent"
      cat <<'EOF'
        haiku     sonnet     opus     gpt     gpt-mini     grok
      EOF
      printf "\n"
    '')
  ];

  programs = {
    # Autojump for directory navigation
    autojump.enable = true;

    bash = {
      enable = true;

      initExtra = ''
        # PATH managed by home.sessionPath

        # SOPS Secrets Environment Variables
        if [ -f /run/secrets/zai_api_key ]; then
          export ZAI_API_KEY="$(cat /run/secrets/zai_api_key)"
        fi
        if [ -f /run/secrets/brave_api_key ]; then
          export BRAVE_API_KEY="$(cat /run/secrets/brave_api_key)"
        fi

        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

        # tv: cd a directorio
        d() { local dir; dir=$(tv dirs) && [ -n "$dir" ] && cd "$dir"; }
        # tv: cd a worktree
        w() { local dir; dir=$(tv git-worktrees) && [ -n "$dir" ] && cd "$dir"; }
        # tv: historial
        h() { tv bash-history; }
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        # PATH managed by home.sessionPath

        # SOPS Secrets Environment Variables
        if test -f /run/secrets/zai_api_key
          set -gx ZAI_API_KEY (cat /run/secrets/zai_api_key)
        end

        if test -f /run/secrets/brave_api_key
          set -gx BRAVE_API_KEY (cat /run/secrets/brave_api_key)
        end

        if command -v wt >/dev/null 2>&1
          eval (wt config shell init fish)
        end

        # tv: cd a directorio
        function d; set dir (tv dirs); test -n "$dir" && cd $dir; end
        # tv: cd a worktree
        function w; set dir (tv git-worktrees); test -n "$dir" && cd $dir; end
        # tv: historial
        function h; tv fish-history; end
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = lib.mkOrder 1200 ''
        # PATH managed by home.sessionPath

        # SOPS Secrets Environment Variables
        if [ -f /run/secrets/zai_api_key ]; then
          export ZAI_API_KEY="$(cat /run/secrets/zai_api_key)"
        fi

        if [ -f /run/secrets/brave_api_key ]; then
          export BRAVE_API_KEY="$(cat /run/secrets/brave_api_key)"
        fi

        # WT Integration
        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

        # tv: cd a directorio
        d() { local dir; dir=$(tv dirs) && [ -n "$dir" ] && cd "$dir"; }
        # tv: cd a worktree
        w() { local dir; dir=$(tv git-worktrees) && [ -n "$dir" ] && cd "$dir"; }
        # tv: historial
        h() { tv zsh-history; }
      '';
    };
  };
}
