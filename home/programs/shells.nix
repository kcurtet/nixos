# ============================================================================
# Fish & Zsh Shell Configuration
# ============================================================================
{ lib, ... }:

{
  programs = {
    # Autojump for directory navigation
    programs.autojump.enable = true;

    bash = {
      enable = true;

      initExtra = ''
        for p in "$HOME/.npm-global/bin" "$HOME/.local/bin" "$HOME/.bun/bin"; do
          [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]] && export PATH="$p:$PATH"
        done

        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        for p in $HOME/.npm-global/bin $HOME/.local/bin $HOME/.bun/bin
          if test -d $p; and not contains $p $PATH
            set -gx PATH $p $PATH
          end
        end

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
        for p in "$HOME/.npm-global/bin" "$HOME/.local/bin" "$HOME/.bun/bin"; do
          [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]] && export PATH="$p:$PATH"
        done

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
