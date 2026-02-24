# ============================================================================
# Library Functions and Constants
# ============================================================================
{ lib }:

let
  themes = import ./themes.nix;
in
{
  inherit (themes) colors gtk gtkPackage cursor lazygit;

  # User constants
  username = "kx";
  fullName = "Kevin Curtet";
  userEmail = "kcurtet@gmail.com";

  # Helper to generate LazyGit theme
  mkLazyGitTheme = themes.lazygit themes.colors;

  # Helper to create a host configuration
  mkHost = { name, system ? "x86_64-linux", extraModules ? [] }:
    { pkgs, inputs, ... }@args:
    lib.nixosSystem {
      inherit system;
      specialArgs = args // { inherit inputs; lib = lib // (import ./. { inherit lib; }); };
      modules = extraModules;
    };
}
