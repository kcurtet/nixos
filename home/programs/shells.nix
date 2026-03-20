# ============================================================================
# Fish & Zsh Shell Configuration
# ============================================================================
{ lib, ... }:

{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;

      initExtra = ''
        if [ -f "$HOME/.profile" ] && [ -z "$__HM_SESS_VARS_SOURCED" ]; then
          . "$HOME/.profile"
        fi

        # ============================================================================
        # SOPS Secrets Environment Variables
        # ============================================================================
        if [ -f /run/secrets/zai_api_key ]; then
          export ZAI_API_KEY="$(cat /run/secrets/zai_api_key)"
        fi

        if [ -f /run/secrets/brave_api_key ]; then
          export BRAVE_API_KEY="$(cat /run/secrets/brave_api_key)"
        fi

        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
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
