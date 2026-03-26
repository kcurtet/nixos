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
# Beads Workflow Context

> **Context Recovery**: Run `bd prime` after compaction, clear, or new session
> Hooks auto-call this in Claude Code when .beads/ detected

# 🚨 SESSION CLOSE PROTOCOL 🚨

**CRITICAL**: Before saying "done" or "complete", you MUST run this checklist:

```
[ ] 1. git status              (check what changed)
[ ] 2. git add <files>         (stage code changes)
[ ] 3. git commit -m "..."     (commit code)
[ ] 4. git push                (push to remote)
```

**NEVER skip this.** Work is not done until pushed.

## Core Rules
- **Default**: Use beads for ALL task tracking (`bd create`, `bd ready`, `bd close`)
- **Prohibited**: Do NOT use TodoWrite, TaskCreate, or markdown files for task tracking
- **Workflow**: Create beads issue BEFORE writing code, mark in_progress when starting
- **Memory**: Use `bd remember "insight"` for persistent knowledge across sessions. Do NOT use MEMORY.md files — they fragment across accounts. Search with `bd memories <keyword>`.
- Persistence you don't need beats lost context
- Git workflow: beads auto-commit to Dolt, run `git push` at session end
- Session management: check `bd ready` for available work

## Essential Commands

### Finding Work
- `bd ready` - Show issues ready to work (no blockers)
- `bd list --status=open` - All open issues
- `bd list --status=in_progress` - Your active work
- `bd show <id>` - Detailed issue view with dependencies

### Creating & Updating
- `bd create --title="Summary of this issue" --description="Why this issue exists and what needs to be done" --type=task|bug|feature --priority=2` - New issue
  - Priority: 0-4 or P0-P4 (0=critical, 2=medium, 4=backlog). NOT "high"/"medium"/"low"
- `bd update <id> --claim` - Claim work
- `bd update <id> --assignee=username` - Assign to someone
- `bd update <id> --title/--description/--notes/--design` - Update fields inline
- `bd close <id>` - Mark complete
- `bd close <id1> <id2> ...` - Close multiple issues at once (more efficient)
- `bd close <id> --reason="explanation"` - Close with reason
- **Tip**: When creating multiple issues/tasks/epics, use parallel subagents for efficiency
- **WARNING**: Do NOT use `bd edit` - it opens $EDITOR (vim/nano) which blocks agents

### Dependencies & Blocking
- `bd dep add <issue> <depends-on>` - Add dependency (issue depends on depends-on)
- `bd blocked` - Show all blocked issues
- `bd show <id>` - See what's blocking/blocked by this issue

### Sync & Collaboration
- `bd dolt push` - Push beads to Dolt remote
- `bd dolt pull` - Pull beads from Dolt remote
- `bd search <query>` - Search issues by keyword

### Project Health
- `bd stats` - Project statistics (open/closed/blocked counts)
- `bd doctor` - Check for issues (sync problems, missing hooks)
- `bd doctor --check=conventions` - Check for convention drift (lint, stale, orphans)

### Quality Tools
- `bd create --validate` - Check description has required sections
- `bd create --acceptance="criteria"` - Set acceptance criteria (checked by --validate)
- `bd create --design="decisions"` - Record design decisions
- `bd create --notes="context"` - Add supplementary notes
- `bd config set validation.on-create warn` - Auto-validate on every create
- `bd lint` - Check existing issues for missing sections

### Lifecycle & Hygiene
- `bd defer <id> --until="date"` - Defer work to a future date
- `bd supersede <id> --with=<new-id>` - Mark issue as superseded
- `bd close <id> --suggest-next` - Show newly unblocked issues after closing
- `bd stale` - Find issues with no recent activity
- `bd orphans` - Find issues with broken dependencies
- `bd preflight` - Pre-PR checks (lint, stale, orphans)
- `bd human <id>` - Flag for human decision (list/respond/dismiss)

### Structured Workflows
- `bd formula list` - See available workflow templates
- `bd mol pour <name>` - Start structured workflow from formula

## Common Workflows

**Starting work:**
```bash
bd ready           # Find available work
bd show <id>       # Review issue details
bd update <id> --claim  # Claim it
```

**Completing work:**
```bash
bd close <id1> <id2> ...    # Close all completed issues at once
git add . && git commit -m "..."  # Commit code changes
git push                    # Push to remote
```

**Creating dependent work:**
```bash
# Run bd create commands in parallel (use subagents for many items)
bd create --title="Implement feature X" --description="Why this issue exists and what needs to be done" --type=feature
bd create --title="Write tests for X" --description="Why this issue exists and what needs to be done" --type=task
bd dep add beads-yyy beads-xxx  # Tests depend on Feature (Feature blocks tests)
```

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
