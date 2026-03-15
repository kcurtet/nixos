# ============================================================================
# Development Tools
# ============================================================================
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Cloud tools
    hcloud

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

    # JavaScript/TypeScript development
    nodejs
    pnpm
    bun
    typescript-language-server
    prettier
    eslint

    # Python development
    python3
    pylint
    black

    # Lua development
    lua
    stylua
    lua-language-server

    # Fennel development
    luaPackages.fennel
    fennel-ls
  ];
}
