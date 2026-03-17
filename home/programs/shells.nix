# ============================================================================
# Fish & Zsh Shell Configuration
# ============================================================================
{ config, pkgs, ... }:

{
  # ============================================================================
  # Fish Shell
  # ============================================================================
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # ============================================================================
      # SOPS Secrets Environment Variables
      # ============================================================================
      if test -f /run/secrets/zai_api_key
        set -gx ZAI_API_KEY (cat /run/secrets/zai_api_key)
      end

      if test -f /run/secrets/brave_api_key
        set -gx BRAVE_API_KEY (cat /run/secrets/brave_api_key)
      end

      # ============================================================================
      # WT Integration
      # ============================================================================
      if command -v wt >/dev/null 2>&1
        eval (wt config shell init fish)
      end

      # ============================================================================
      # Theme
      # ============================================================================
      # Use the default theme or customize as needed
    '';

    shellAliases = {
      # Basic aliases (extended aliases from aliases.nix will be available)
    };

    functions = {
      fish_greeting = "";  # Disable default greeting
    };
  };

  # ============================================================================
  # Zsh Shell
  # ============================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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

      # ============================================================================
      # WT Integration
      # ============================================================================
      if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
    '';
  };

  # ============================================================================
  # Set Fish as Default Shell
  # ============================================================================
  home.sessionVariables = {
    SHELL = "${pkgs.fish}/bin/fish";
  };

  # Make fish the default shell
  programs.fish.shellInit = ''
    # Ensure we're running fish
  '';

  # Configure shell as the default
  home.preferredShell = pkgs.fish;
}
