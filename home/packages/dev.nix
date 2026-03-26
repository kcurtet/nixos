# ============================================================================
# Development Tools
# ============================================================================
{ pkgs, ... }:
let
  emacs-with-vterm = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (ep: [ ep.vterm ]);
in
{
  home.packages = with pkgs; [
    playwright-driver
    playwright.browsers
    playwright

    # Cloud tools
    hcloud

    # build tools
    just

    # Editors
    neovim
    emacs-with-vterm
    vscode-fhs

    # AI assistants
    opencode
    claude-code
    copilot-cli
    crush

    # nix
    deadnix
    statix

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
