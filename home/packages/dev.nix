# ============================================================================
# Development Tools
# ============================================================================
{pkgs, ...}: {
  home.packages = with pkgs; [
    # build tools
    just

    # Editors
    neovim
    emacs
    vscode-fhs

    # AI assistants
    opencode
    claude-code
    copilot-cli
    crush

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
