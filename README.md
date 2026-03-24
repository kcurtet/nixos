# NixOS Configuration

A modular, clean NixOS configuration using flakes and Home Manager.

## Structure

```
nixos/
├── flake.nix              # Flake entry point
├── hosts/                 # Per-machine configurations
│   └── panther/           # Main laptop
│       ├── default.nix    # Host configuration
│       ├── hardware.nix   # Hardware scan
│       └── networking.nix # Network settings
├── modules/               # Reusable NixOS modules
│   ├── desktop/gnome/     # GNOME desktop
│   ├── gaming/            # Gaming stack
│   ├── laptop/            # Power management
│   ├── nvidia/            # NVIDIA graphics
│   ├── services/          # System services
│   └── virtualization/    # Docker & libvirtd
├── home/                  # Home Manager configuration
│   ├── programs/          # Program configs
│   ├── packages/          # Package sets
│   ├── themes/            # Theme configurations
│   └── services/          # User services
├── lib/                   # Helper functions & constants
├── overlays/              # Nixpkgs overlays
└── scripts/               # Custom shell scripts
```

## Commands

| Command | Description |
|---------|-------------|
| `nix-apply` | Commit changes and apply configuration immediately (now prompts before committing; use `NIX_APPLY_AUTO=1` or `nix-apply --yes` for non-interactive) |
| `nboot`    | Apply changes on next boot |
| `nix-up`   | Update flake inputs (nixpkgs, home-manager, etc.) |

## Adding a New Host

1. Create a new directory under `hosts/`:
   ```bash
   mkdir -p hosts/lynx
   ```

2. Generate hardware config:
   ```bash
   sudo nixos-generate-config --dir ./hosts/lynx
   ```

3. Create `hosts/lynx/default.nix`:
   ```nix
   { inputs, pkgs, lib, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ./networking.nix
       # Add required modules...
     ];

     networking.hostName = "lynx";
     # ... rest of configuration
   }
   ```

4. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     panther = mkHost "panther";
     lynx = mkHost "lynx";
   };
   ```

## Features

- **Nord Theme**: Consistent theming across all applications
- **Modular Design**: Easy to enable/disable features via module options
- **Multi-host Ready**: Simple structure for managing multiple machines
- **Development Ready**: Pre-configured for Nix, Node.js, Python, Lua

## Modules

### Gaming
```nix
gaming.enable = true;  # Steam, GameMode, Gamescope, Wine
```

### NVIDIA
```nix
hardware.nvidiaConfig = {
  enable = true;
  prime = {
    enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
};
```

### Virtualization
```nix
virtualization = {
  docker.enable = true;
  libvirtd.enable = true;
};
```

### Services
```nix
my.services = {
  syncthing.enable = true;
  tailscale.enable = true;
  flatpak.enable = true;
};
```

## Rebuilding

```bash
# Commit changes and apply immediately
nix-apply

# Or manually:
# sudo nixos-rebuild switch --flake .#panther
```

## Development Shell

```bash
nix develop
# Provides: nil, nixd, alejandra, statix, deadnix
```

## CI & Pre-commit

This repository includes a GitHub Actions workflow at `.github/workflows/ci.yml` which runs `nix flake check` plus formatter and linter checks on pushes and pull requests.

A sample local pre-commit hook is available at `.githooks/pre-commit`. To enable it locally:

```bash
git config core.hooksPath .githooks
```

The hook runs `nixfmt-tree`, `statix` and `deadnix`. It requires `nix` to be installed and may download dependencies the first time it runs.

## Notes

- Secrets are managed with sops/sops-nix. Do not commit plaintext secrets. `secrets/secrets.yaml` is encrypted with sops and should remain encrypted.
- `nix-apply` now prompts before committing uncommitted changes. Use `NIX_APPLY_AUTO=1 nix-apply` or `nix-apply --yes` to skip the prompt.
