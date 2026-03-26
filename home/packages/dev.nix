# ============================================================================
# Development Tools
# ============================================================================
{ pkgs, ... }:
let
  emacs-with-vterm = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (ep: [ ep.vterm ]);

  # Tree-sitter grammars from nixpkgs
  treesitter-grammars = with pkgs.tree-sitter-grammars; [
    tree-sitter-bash
    tree-sitter-json
    tree-sitter-nix
    tree-sitter-python
    tree-sitter-rust
    tree-sitter-toml
    tree-sitter-yaml
    tree-sitter-javascript
    tree-sitter-typescript
    tree-sitter-tsx
    tree-sitter-hyprlang
  ];

  # Create a directory with all grammars linked with Emacs naming convention
  treesitter-dir = pkgs.runCommand "emacs-treesitter-grammars" { } ''
    mkdir -p $out
    ${pkgs.lib.concatStrings (map (grammar: ''
      lang=$(basename ${grammar} | sed 's/tree-sitter-//' | sed 's/-[0-9].*//')
      ln -sf ${grammar}/parser $out/libtree-sitter-$lang.so
      if [ -d "${grammar}/queries" ]; then
        mkdir -p $out/$lang-queries
        ln -sf ${grammar}/queries/* $out/$lang-queries/ 2>/dev/null || true
      fi
    '') treesitter-grammars)}
  '';
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

  # Link tree-sitter grammars to ~/.config/emacs/tree-sitter
  home.file.".config/emacs/tree-sitter".source = treesitter-dir;
}
