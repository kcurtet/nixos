# ============================================================================
# Zellij Terminal Multiplexer Configuration
# ============================================================================
{ ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "nord";
    };
  };
}
