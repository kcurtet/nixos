# ============================================================================
# NixOS Flake Configuration
# ============================================================================
{
  description = "NixOS configuration with modular structure";

  # ============================================================================
  # Flake Settings
  # ============================================================================
  nixConfig = {
    allowUnfree = true;
    extra-trusted-users = [ "kx" ];
    experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaWLxGQfRxcK5I2J8L4VkPp1J2xZlXQXb9I3yD0="
      "devenv.cachix.org-1:w1cLU/i8DQ20/9keT+9L4DThyx+2Biv4fT5GwhJyC8="
    ];
  };

  # ============================================================================
  # Flake Inputs
  # ============================================================================
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Neovim configuration
    nixvim.url = "github:kcurtet/nixvim";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
  };

  # ============================================================================
  # Flake Outputs
  # ============================================================================
  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      nixvim,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Helper function to create NixOS configurations
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];
        };
    in
    {
      # ============================================================================
      # NixOS Configurations
      # ============================================================================
      nixosConfigurations = {
        panther = mkHost "panther";
        # Add more hosts here:
        # lynx = mkHost "lynx";
      };

      # ============================================================================
      # Formatter (for `nix fmt`)
      # ============================================================================
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      # ============================================================================
      # Development Shells
      # ============================================================================
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nixd
          nixfmt-tree
          statix
          deadnix
          sops
          nixvim.packages.${system}.default
        ];
      };
    };
}
