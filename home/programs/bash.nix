# ============================================================================
# Bash Shell Configuration
# ============================================================================
{ ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
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
}
