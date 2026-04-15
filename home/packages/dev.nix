# ============================================================================
# Development Tools
# ============================================================================
{ pkgs, ... }:
let
  treesitter-grammars = pkgs.emacsPackages.treesit-grammars.with-grammars (p: [
    p.tree-sitter-bash
    p.tree-sitter-json
    p.tree-sitter-nix
    p.tree-sitter-python
    p.tree-sitter-rust
    p.tree-sitter-toml
    p.tree-sitter-yaml
    p.tree-sitter-javascript
    p.tree-sitter-typescript
    p.tree-sitter-tsx
    p.tree-sitter-hyprlang
  ]);

  emacs-with-packages = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (ep: [
    ep.vterm
    treesitter-grammars
  ]);
in
{
  home.packages = with pkgs; [
    # C compiler for ad-hoc tree-sitter compilation
    gcc

    playwright-driver
    playwright.browsers
    playwright

    # Cloud tools
    hcloud

    # build tools
    just

    # Editors
    neovim
    emacs-with-packages
    vscode-fhs

    # nix
    deadnix
    statix

    # JavaScript/TypeScript development
    nodejs
    pnpm
    bun
    tsx
    typescript-language-server
    prettier
    eslint

    # Python development
    (python3.withPackages (
      p: with p; [
        easyocr
        pillow
        pdf2image
        imagemagick
        pytesseract

      ]
    ))
    pylint
    black
    uv

    cudatoolkit

    # Lua development
    lua
    stylua
    lua-language-server

    # Fennel development
    luaPackages.fennel
    fennel-ls

    # debug
    xxd
  ];

}
