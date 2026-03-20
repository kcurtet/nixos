# AGENTS.md

NixOS Configuration Repository - Agent Guidelines

## Overview

This is a personal NixOS configuration for a laptop named **panther**.

**Key Facts:**
- **User:** `kx` (defined in `lib/default.nix` as `username`)
- **Hardware:** Laptop with NVIDIA RTX 3070 + Intel i7 (hybrid graphics via Prime)
- **Desktops:** GNOME (default), Hyprland (Wayland)
- **Flake URL:** `.#panther`

**Available Specialisations:**
- `panther` (default) - Full NVIDIA + Intel setup
- `disable-nvidia` - Intel only (battery saving)
- `on-the-go` - Portable mode
- `disable-intel` - NVIDIA only

## Skill References

When working on this NixOS configuration, load these skills for authoritative guidance:

| Skill | When to Use |
|-------|-------------|
| `nix-language` | Nix syntax, functions, patterns, lib operations |
| `nix-flakes` | flake.nix, devShells, inputs/outputs |
| `nix-system` | NixOS modules, Home Manager, disko, sops-nix |

**Load before:** Writing new modules, modifying flake.nix, adding Home Manager configs.

## Build & Development Commands

### Rebuilding System

```bash
nix-up                    # Update flake inputs and rebuild
nix-apply                 # Apply configuration changes immediately
nboot                     # Apply changes on next boot

# Direct flake commands:
sudo nixos-rebuild switch --flake .#panther           # Apply now
sudo nixos-rebuild dry-build --flake .#panther        # Test build
sudo nixos-rebuild switch --flake .#panther-disable-nvidia  # Use specialisation
```

### Development Shell

```bash
nix develop                # Enter dev shell with linting tools
# Provides: nixd, nixfmt, statix, deadnix, treefmt
```

### Linting & Formatting

```bash
statix check .             # Lint for Nix anti-patterns
deadnix .                  # Find and remove dead code
nixfmt-tree .              # Format all Nix files (preferred)
treefmt                    # Alternative formatter

# Verify single file syntax:
nix-instantiate --parse <file>.nix > /dev/null
```

### Pre-Commit Workflow

**MANDATORY before every commit:**

```bash
# Quick one-liner:
statix check . && deadnix . && nixfmt-tree . && sudo nixos-rebuild dry-build --flake .#panther
```

## Project Structure

```
.
├── flake.nix              # Flake entry point, host definitions, mkHost helper
├── hosts/
│   └── panther/           # Host-specific configuration
│       ├── default.nix    # Main config, imports modules, specialisations
│       ├── hardware.nix   # Filesystems, hardware scan
│       └── networking.nix # Hostname, network manager
├── modules/               # Reusable NixOS modules (options + config)
│   ├── desktop/
│   │   ├── gnome/         # GNOME desktop module
│   │   └── hyprland/      # Hyprland Wayland compositor
│   ├── gaming/            # Steam, Wine, gamescope
│   ├── laptop/            # Power management, TLP
│   ├── nvidia/            # NVIDIA + Prime (offload/sync modes)
│   ├── services/          # Syncthing, Tailscale, Docker
│   └── virtualization/    # Docker & libvirtd
├── home/                  # Home Manager configuration
│   ├── default.nix        # Entry point, imports all home configs
│   ├── programs/          # Per-program configs (git, ssh, foot, hyprland)
│   ├── packages/          # Package sets (dev, gui, cli)
│   ├── themes/            # Nord theme
│   └── services/          # User-level systemd services
├── lib/
│   ├── default.nix        # username, email, helper functions
│   └── themes.nix         # Nord color palette
├── scripts/               # nix-apply, nboot, nix-up (added to PATH)
└── secrets/               # sops-nix encrypted files
```

## Key Architecture

### lib/default.nix - The Source of Truth

```nix
# lib/default.nix defines global constants used everywhere
{
  username = "kx";
  email = "user@example.com";
  # ... helper functions
}
```

**Importing lib from different locations:**
```nix
# From modules/*/default.nix:
lib = import ../../lib;

# From hosts/panther/default.nix:
lib = import ../lib;

# From home/programs/*.nix:
lib = import ../../lib;
```

### Flake Structure

The flake uses `mkHost` helper to reduce boilerplate:

```nix
# flake.nix (simplified)
{
  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.panther = mkHost "panther";
  };
}
```

**What mkHost does:**
1. Imports `hosts/panther/default.nix`
2. Passes `inputs` via `specialArgs`
3. Wires in Home Manager with user `kx`
4. Applies overlays

### Home Manager Integration

Home Manager is wired into the NixOS configuration (standalone HM, not module):

```nix
# hosts/panther/default.nix
home-manager.users.kx = import ../../home;
```

**Split:**
- `modules/` → System-level (services, hardware, desktop)
- `home/` → User-level (programs, packages, themes)

## Code Style Guidelines

### Module Pattern

All modules follow this structure:

```nix
# modules/my-feature/default.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.feature;
  lib = import ../../lib;  # Import at top of let block
in
{
  options.my.feature = {
    enable = lib.mkEnableOption "My feature";
    setting = lib.mkOption {
      type = lib.types.str;
      default = "/home/${lib.username}/data";  # Use lib.username
      description = "Description";
    };
  };

  config = lib.mkIf cfg.enable {
    # Actual configuration
    services.myService.enable = true;
  };
}
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Modules | lowercase-hyphen | `gaming`, `nvidia`, `virtualization` |
| Options | `my.{category}` | `my.services.syncthing.enable` |
| Hosts | lowercase | `panther` |
| Local vars | snake_case | `data_dir`, `config_file` |
| Functions | camelCase | `mkHost`, `ifThenElse` |

### File Headers

```nix
# ============================================================================
# Section Name
# ============================================================================
```

79-character separator lines.

## Common Tasks

### Add a System Package

```nix
# modules/desktop/hyprland/default.nix
environment.systemPackages = with pkgs; [
  grim
  slurp
];
```

### Add a User Package

```nix
# home/packages/cli.nix
home.packages = with pkgs; [
  ripgrep
  fd
];
```

### Add a New Module

1. Create `modules/my-module/default.nix` with options + config
2. Import in `hosts/panther/default.nix`:
   ```nix
   imports = [ ../../modules/my-module ];
   ```
3. Enable via option or module default

### Add a Home Manager Program Config

1. Create `home/programs/myprogram.nix`
2. Import in `home/default.nix`:
   ```nix
   imports = [ ./programs/myprogram.nix ];
   ```

### Enable/Disable a Module

Most modules have `enable` options:

```nix
# hosts/panther/default.nix
my.services.syncthing.enable = true;
gaming.enable = true;
```

### Switch Desktop Environment

```bash
# Use specialisation
sudo nixos-rebuild switch --flake .#panther  # GNOME (default)

# Or enable Hyprland in host config and rebuild
```

## Testing

No automated tests. Validate with:

```bash
sudo nixos-rebuild dry-build --flake .#panther
```

## Key Patterns

| Pattern | How It's Done |
|---------|---------------|
| Flake inputs | `specialArgs = { inherit inputs; }` |
| Overlays | `nixpkgs.overlays = import ../../overlays { inherit inputs pkgs; }` |
| Home Manager | `home-manager.users.kx = import ../../home;` |
| Custom scripts | `scripts/` directory added to PATH via `environment.systemPackages` |
| Theming | Nord theme in `lib/themes.nix`, imported where needed |
| Secrets | sops-nix, key at `~/.config/sops/age/keys.txt` |
