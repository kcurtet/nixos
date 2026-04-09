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
  ];

  programs = {
    # Zoxide for smart directory navigation (replaces autojump)
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

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

        if [ -f ~/.stripe/stripe-completion.bash ]; then
          source ~/.stripe/stripe-completion.bash
        fi

        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
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
      '';
    };
  };
}
