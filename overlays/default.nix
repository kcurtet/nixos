# ============================================================================
# Custom Overlays
# ============================================================================
{ inputs, pkgs }:
[
  # Neovim from nixvim flake
  (final: prev: {
    neovim = inputs.nixvim.packages.${pkgs.stdenv.system}.default;
  })

  # Custom packages
  (final: prev: {
    custom = import ../pkgs { pkgs = final; };
  })
]
