# ============================================================================
# Yazi File Manager Configuration
# ============================================================================
{ ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
}
