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

      if [ -f /run/secrets/okx_api_key ]; then
        export OKX_API_KEY="$(cat /run/secrets/okx_api_key)"
      fi

      if [ -f /run/secrets/okx_secret_key ]; then
        export OKX_SECRET_KEY="$(cat /run/secrets/okx_secret_key)"
      fi

      if [ -f /run/secrets/okx_passphrase ]; then
        export OKX_PASSPHRASE="$(cat /run/secrets/okx_passphrase)"
      fi
    '';
  };
}
