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
    extra-trusted-users = ["kx"];
    experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
  };

  # ============================================================================
  # Flake Outputs
  # ============================================================================
  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Helper function to create NixOS configurations
    mkHost = name:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${name}
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
        ];
      };
  in {
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
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

    # ============================================================================
    # Development Shells
    # ============================================================================
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      packages = with nixpkgs.legacyPackages.${system}; [
        nixd
        nixfmt
        statix
        deadnix
        neovim
      ];
    };
  };
}
