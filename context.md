# Code Context

## Repository Overview

**NixOS Configuration** for a laptop named **panther** — a modular, flake-based NixOS setup with Home Manager integration, Nord theming, and NVIDIA hybrid graphics.

- **Remote:** `git@github.com:kcurtet/nixos.git`
- **Host:** `panther` (single machine, extensible via `mkHost`)
- **User:** `kx` (Kevin Curtet)
- **Desktop:** Hyprland (Wayland) with GDM login
- **Hardware:** Intel i7 + NVIDIA RTX 3070 (Prime offload)
- **Flake URL:** `.#panther`
- **Stats:** 47 Nix files, ~3,757 lines of Nix code
- **Last commit:** 2026-04-08

## Relevant Files

### Entry Point
| File | Lines | Purpose |
|------|-------|---------|
| `flake.nix` | 103 | Flake definition: inputs (nixpkgs, home-manager, sops-nix, nixvim), `mkHost` helper, dev shell, formatter |
| `flake.lock` | — | Pinned input versions |

### Library / Shared Constants
| File | Lines | Purpose |
|------|-------|---------|
| `lib/default.nix` | 42 | Source of truth: `username`, `fullName`, `userEmail`, Nord theme exports, `mkHost` helper |
| `lib/themes.nix` | 88 | Nord color palette (16 colors), GTK/cursor theme names, LazyGit theme generator |

### Host Configuration (`hosts/panther/`)
| File | Lines | Purpose |
|------|-------|---------|
| `hosts/panther/default.nix` | 323 | Main host config: imports all modules, Nix settings, boot (systemd-boot), fonts, desktop, audio (PipeWire), keyd, user, GPU, gaming, virtualization, services, overlays, system packages, Home Manager wiring, SOPS secrets |
| `hosts/panther/hardware.nix` | 54 | Filesystems (ext4 `/`, vfat `/boot`, btrfs `/data`), kernel modules, zram swap, Intel microcode |
| `hosts/panther/networking.nix` | 28 | Hostname `panther`, NetworkManager, `/etc/hosts` overrides for arr stack, DNS, firewall |

### System Modules (`modules/`)
| File | Lines | Purpose |
|------|-------|---------|
| `modules/nvidia/default.nix` | 83 | `hardware.nvidiaConfig` options: modesetting, Prime offload, open kernel module toggle |
| `modules/nvidia/specialisations.nix` | 72 | Boot specialisations: `on-the-go` (sync), `disable-intel`, `disable-nvidia` (udev device removal) |
| `modules/desktop/hyprland/default.nix` | 96 | `desktop.hyprland-wayland` options: Hyprland + XWayland, GDM session registration, XDG portals, system packages |
| `modules/gaming/default.nix` | 68 | `gaming` options: Steam, GameMode, Gamescope, Wine, MangoHud, `game-run` wrapper |
| `modules/virtualization/default.nix` | 55 | `virtualization.docker` and `virtualization.libvirtd` options |
| `modules/services/default.nix` | 135 | `my.services.*` options: syncthing, tailscale, tor, flatpak, openssh, ollama, dnsmasq |
| `modules/laptop/default.nix` | 58 | `laptop.powerManagement` options: TLP, CPU governors, battery charge thresholds |

### Home Manager (`home/`)
| File | Lines | Purpose |
|------|-------|---------|
| `home/default.nix` | 68 | Entry point: imports all sub-modules, Emacs symlink, PATH, session variables, XDG mime |
| `home/aliases.nix` | 67 | Shell aliases: editors (e,nvim), tools (g=lazygit, y=yazi, z=zi), git shortcuts, television channels, pi-coding-agent shortcuts |
| `home/themes/nord.nix` | 88 | Nord theme applied to: dconf/GTK, lazygit, bat, zellij, tmux, ghostty |
| `home/packages/cli.nix` | ~60 | CLI packages: eza, btop, fd, ripgrep, jq, delta, gh, glow, ffmpeg, yt-dlp, etc. |
| `home/packages/dev.nix` | ~60 | Dev packages: emacs-pgtk, neovim, vscode-fhs, nodejs, bun, python3, lua, AI tools (claude-code, copilot-cli, opencode) |
| `home/packages/gui.nix` | ~30 | GUI packages: brave, librewolf, spotify, telegram, discord, obsidian, libreoffice |
| `home/programs/default.nix` | 27 | Imports 22 program configs |
| `home/programs/shells.nix` | ~130 | Bash, Fish, Zsh configs with zoxide, SOPS secret loading, television (tv) integration, custom functions |
| `home/programs/hyprland.nix` | 138 | `programs.hyprland-config`: dotfile symlinks for Hyprland confs, waybar, rofi, cursor, screenshot dir |
| `home/programs/git.nix` | ~80 | Git + delta with colorblind-friendly Nord theme (side-by-side, orange=added, blue=removed) |
| `home/programs/direnv.nix` | 10 | direnv + nix-direnv |
| `home/programs/ssh.nix` | 12 | SSH with `TERM=xterm-256color` default |
| `home/programs/dunst.nix` | 30 | Dunst notifications with Nord colors |
| `home/services/default.nix` | 5 | tailscale-systray |

### Custom Packages & Overlays
| File | Lines | Purpose |
|------|-------|---------|
| `overlays/default.nix` | 13 | Two overlays: neovim from nixvim flake, custom packages from `pkgs/` |
| `pkgs/default.nix` | 4 | Custom package set (currently empty) |
| `scripts/default.nix` | ~80 | Shell scripts as derivations: `nix-apply` (commit+rebuild), `nboot` (rebuild on boot), `nix-up` (flake update) |
| `scripts/emacs-up` | ~300 | Emacs straight.el package manager CLI (update, rebuild, freeze, thaw, clean, purge, status) |

### Dotfiles (symlinked, editable without rebuild)
| Directory | Contents |
|-----------|----------|
| `dotfiles/hypr/` | `hyprland.conf`, `hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf`, `scripts/` |
| `dotfiles/emacs/` | `early-init.el`, `init.el`, `patches/` |
| `dotfiles/waybar/` | `config.json`, `style.css` |
| `dotfiles/rofi/` | `nord.rasi` |
| `dotfiles/wallpapers/` | Wallpaper images |
| `dotfiles/swaync/` | SwayNC config |

### Secrets
| File | Purpose |
|------|---------|
| `secrets/secrets.yaml` | SOPS-encrypted: `zai_api_key`, `brave_api_key` |
| `.sops.yaml` | SOPS configuration (age key reference) |

## Patterns Found

### 1. Module Pattern (System-level)
Every module in `modules/` follows:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.category.feature;  # or config.hardware.nvidiaConfig, config.gaming, etc.
  myLib = import ../../lib { inherit lib; };  # when username/colors needed
in {
  options.my.category.feature = {
    enable = lib.mkEnableOption "...";
    # ... more options
  };
  config = lib.mkIf cfg.enable {
    # ... actual configuration
  };
}
```

### 2. Home Manager Program Pattern
Every program config in `home/programs/`:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.my-program;
in {
  options.programs.my-program = {
    enable = lib.mkEnableOption "my program";
  };
  config = lib.mkIf cfg.enable {
    programs.actualProgram = { ... };
    home.packages = [ ... ];
  };
}
```

### 3. Dotfile Symlink Pattern
Hyprland configs, Emacs, Waybar, and Rofi use `mkOutOfStoreSymlink` to allow live editing without rebuilds:
```nix
home.file.".config/hypr/hyprland.conf".source =
  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nixos-config/dotfiles/hypr/hyprland.conf";
```

### 4. Flake Input Wiring
- `specialArgs = { inherit inputs; }` passes flake inputs to all modules
- Overlays access `inputs.nixvim` for custom neovim
- Home Manager wired as NixOS module (not standalone): `home-manager.users.kx = import ../../home;`

### 5. Option Namespacing
- System modules: `hardware.nvidiaConfig`, `desktop.hyprland-wayland`, `gaming`, `virtualization`, `my.services.*`, `laptop.powerManagement`
- Home programs: `programs.hyprland-config`, `programs.rofi-config`, `programs.foot-config`, `programs.git.settings`, `gtk-config`

### 6. Theming
- Nord color palette defined in `lib/themes.nix`, re-used across: GTK, lazygit, bat, zellij, tmux, ghostty, delta (git), dunst
- GTK theme: "Nordic" (package: `nordic`)
- Cursor: "Bibata-Modern-Classic" (Nordzy alt)
- Delta git diff uses colorblind-friendly variant (orange=added, blue=removed)

### 7. Script Derivations
Custom scripts (`nix-apply`, `nboot`, `nix-up`, `emacs-up`) are defined as `writeShellScriptBin` / `writeScriptBin` derivations in `scripts/default.nix`, then added to `environment.systemPackages` via `builtins.attrValues scripts`.

## Dependencies

### Flake Inputs
| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | `NixOS/nixpkgs/nixos-unstable` | Package set (followed by others) |
| `home-manager` | `nix-community/home-manager` | User-level config management |
| `sops-nix` | `Mic92/sops-nix` | Secrets encryption with age |
| `nixvim` | `kcurtet/nixvim` | Neovim configuration (custom fork) |

### Key System Services
- **Display:** GDM + Hyprland (Wayland)
- **Audio:** PipeWire (with PulseAudio compat)
- **VPN:** Tailscale (with SSH)
- **Sync:** Syncthing
- **DNS:** dnsmasq (local, 127.0.0.1)
- **Containers:** Docker
- **VMs:** libvirtd (KVM/QEMU)
- **AI:** Ollama (localhost:11434)
- **Anonymity:** Tor (GeoIP disabled)
- **Keyboard:** keyd (capslock → overload(control, esc))

### Key User Programs
- **Shells:** Bash, Fish, Zsh (all configured with zoxide, television, SOPS secrets)
- **Editors:** Neovim (nixvim), Emacs (straight.el, pgtk), VS Code (FHS)
- **Terminal:** Ghostty, Kitty, Foot
- **Git:** delta (colorblind Nord theme), lazygit
- **AI:** claude-code, copilot-cli, opencode, crush
- **Browsers:** Brave, LibreWolf, Chromium, Nyxt, Tor Browser
- **Dev:** Node.js, Bun, pnpm, Python 3, Lua, Fennel

### Development Tools (dev shell)
- `nixd` (LSP), `nixfmt-tree` (formatter), `statix` (linter), `deadnix` (dead code), `sops`

## Architecture Diagram

```
flake.nix
├── hosts/panther/          ← mkHost("panther")
│   ├── default.nix         ← Imports all modules, wires Home Manager
│   ├── hardware.nix        ← Filesystems, kernel, zram
│   └── networking.nix      ← hostname, NetworkManager, DNS, firewall
│
├── modules/                ← Reusable NixOS modules (options + config)
│   ├── nvidia/             ← hardware.nvidiaConfig + specialisations
│   ├── desktop/hyprland/   ← desktop.hyprland-wayland
│   ├── gaming/             ← Steam, GameMode, Gamescope, Wine
│   ├── virtualization/     ← Docker, libvirtd
│   ├── services/           ← my.services.* (7 services)
│   └── laptop/             ← TLP power management
│
├── home/                   ← Home Manager (user-level)
│   ├── programs/           ← 22 program configs
│   ├── packages/           ← cli.nix, dev.nix, gui.nix
│   ├── themes/nord.nix     ← Applied everywhere
│   ├── services/           ← tailscale-systray
│   └── aliases.nix         ← Shell aliases
│
├── lib/                    ← Shared constants & helpers
│   ├── default.nix         ← username, email, mkHost helper
│   └── themes.nix          ← Nord color palette
│
├── overlays/               ← Package overrides (neovim from nixvim)
├── pkgs/                   ← Custom package derivations (empty)
├── scripts/                ← nix-apply, nboot, nix-up, emacs-up
├── dotfiles/               ← Symlinked configs (hypr, emacs, waybar, rofi)
└── secrets/                ← SOPS-encrypted secrets.yaml
```

## Build Commands

```bash
# Apply changes
nix-apply                          # Commit + rebuild switch
sudo nixos-rebuild switch --flake .#panther

# Test build (no changes)
sudo nixos-rebuild dry-build --flake .#panther

# Update flake inputs
nix-up                             # nix flake update

# Lint & format
statix check . && deadnix . && nixfmt-tree .

# Enter dev shell
nix develop
```
