# ============================================================================
# Development Tools
# ============================================================================
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors
    neovim
    emacs

    # AI assistants
    opencode
    claude-code
    copilot-cli

    # Cloud tools
    hcloud

    # JavaScript/TypeScript development
    nodejs
    pnpm
    bun
    typescript
    typescript-language-server
    prettier
    eslint

    # Python development
    python3
    pylint
    black

    # Lua development
    lua
    luaPackages.fennel
    stylua
    lua-language-server
    fennel-ls
  ];
}
