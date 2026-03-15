# AGENTS.md

NixOS Configuration Repository - Agent Guidelines

## Build & Development Commands

### Rebuilding System

```bash
nix-up                    # Update flake inputs and rebuild
nix-apply                    # Apply configuration changes immediately
nboot                       # Apply changes on next boot
```

### Development Shell

```bash
nix develop                # Enter dev shell with linting tools
# Provides: nixd, nixfmt, statix, deadnix
```

### Linting & Formatting

```bash
nixfmt .                   # Format Nix files
statix check .             # Lint for Nix anti-patterns
deadnix -e .               # Find dead code in Nix files
nixd                       # Nix language server
```

## Project Structure

```
nixos/
├── flake.nix              # Flake entry point, host definitions
├── hosts/                 # Per-machine configurations
│   └── panther/           # Host-specific: default.nix, hardware.nix, networking.nix
├── modules/               # Reusable NixOS modules (options + config)
│   ├── desktop/gnome/     # GNOME desktop module
│   ├── gaming/            # Gaming stack (Steam, Wine, etc.)
│   ├── laptop/            # Power management
│   ├── nvidia/            # NVIDIA graphics with Prime support
│   ├── services/          # System services (Syncthing, Tailscale, etc.)
│   └── virtualization/    # Docker & libvirtd
├── home/                  # Home Manager configuration
│   ├── programs/          # Per-program configs (git, ssh, tmux, etc.)
│   ├── packages/          # Package sets (dev, gui, cli)
│   ├── themes/            # Theme configurations (Nord)
│   ├── services/          # User services
│   └── aliases.nix        # Shell aliases
├── lib/                   # Helper functions & constants
│   ├── default.nix        # Main library (username, email, helpers)
│   └── themes.nix         # Nord theme definitions
├── overlays/              # Nixpkgs overlays
├── scripts/               # Custom shell scripts (nix-apply, nboot, nix-up)
└── README.md              # User documentation
```

## Code Style Guidelines

### File Organization

- Use section headers with 79-character separator lines
- Group related settings under logical sections (e.g., `# System Packages`)
- Host configs in `hosts/{hostname}/`, modules in `modules/{feature}/`

### Imports & Modules

```nix
# Host configuration - import hardware, networking, and required modules
imports = [
  ./hardware.nix
  ./networking.nix
  ../../modules/nvidia
  ../../modules/gaming
  ../../modules/services
];

# Module definition pattern
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services;  # Destructure options
in
{
  options.my.services = { ... };
  config = lib.mkIf cfg.enable { ... };
}
```

### Module Options

```nix
options.my.service = {
  enable = lib.mkEnableOption "My service description";
  dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/home/${lib.username}/data";  # lib imported from ../../lib
    description = "Data directory path";
  };
};
```

### Configuration Activation

```nix
config = lib.mkIf cfg.enable {
  services.myService = {
    enable = true;
    user = lib.username;  # lib imported from ../../lib
  };
};
```

### Naming Conventions

- Modules: Use lowercase with hyphens (`gaming`, `nvidia`, `virtualization`)
- Options: Namespace with `my.{category}` or `hardware.{category}`
- Hosts: Use lowercase names matching directory structure
- Variables: CamelCase for library functions, snake_case for local bindings

### Error Handling & Defaults

- Always provide defaults for module options
- Use `lib.mkDefault` for user-configurable values
- Import lib from ../../lib and use `lib.username` in modules

### Library Functions (lib/)

- Place reusable helpers in `lib/default.nix`
- Theme-related functions in `lib/themes.nix`
- Export using `inherit (themes) colors gtk gtkPackage;`

## Adding New Hosts

1. Create `hosts/{hostname}/` with `default.nix`, `hardware.nix`, `networking.nix`
2. Add to `flake.nix` `nixosConfigurations` using `mkHost "hostname"`
3. Import required modules in host's `default.nix`
4. Set `networking.hostName` and host-specific options

## Module Development Pattern

When creating modules:

1. Define `options` section with `enable` and necessary configuration options
2. Use `lib.mkIf cfg.enable` in `config` to conditionally activate
3. Reference global values via `config.my` (username is in lib/, not config.my)
4. Keep modules single-purpose and composable
5. Document options with clear descriptions

## Key Patterns

- **Flake inputs**: Passed via `specialArgs = {inherit inputs;}`
- **Overlays**: Applied via `nixpkgs.overlays = import ../../overlays { inherit inputs pkgs; };`
- **Home Manager integration**: Use `home-manager.users.{username} = import ../../home;`
- **Helper scripts**: Created in `scripts/` using `pkgs.writeShellScriptBin`
- **Theming**: Nord theme centralized in `lib/themes.nix`, imported across configs

## Testing

No automated test infrastructure. Validate configuration with:

```bash
sudo nixos-rebuild build --flake .#panther  # Dry-run build check
```
