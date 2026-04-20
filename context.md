# Code Context

## Files Retrieved
List with exact line ranges:
1. `flake.nix` (full) — Flake entry point: inputs (nixpkgs, home-manager, sops-nix, nixvim), mkHost helper, panther host
2. `lib/default.nix` (full) — Username `kx`, fullName, email, theme imports, mkHost helper
3. `lib/themes.nix` (full) — Nord color palette (n0-n15), GTK theme name, cursor, lazygit theme generator
4. `hosts/panther/default.nix` (full) — Main host config: imports modules, sets home-manager user kx, NVIDIA prime, services, fonts
5. `home/default.nix` (full) — HM entry: imports themes/programs/packages/services/aliases, enables sway-config/foot-config/rofi-config
6. `home/programs/default.nix` (full) — Index of all program modules (bat, direnv, foot, git, lazygit, rofi, shells, ssh, starship, sway, television, tmux, yazi)
7. `home/programs/sway.nix` (full) — Custom option `programs.sway-config`, symlinks sway config from dotfiles, adds wayland packages
8. `home/programs/foot.nix` (full) — Custom option `programs.foot-config`, Nord-themed foot terminal
9. `home/programs/rofi.nix` (full) — Custom option `programs.rofi-config`, theme from dotfiles
10. `home/programs/git.nix` (full) — Delta with colorblind-friendly Nord theme, git settings
11. `home/themes/nord.nix` (full) — GTK, lazygit, bat, zellij, tmux, ghostty theming via Nord colors
12. `home/services/default.nix` (full) — tailscale-systray only
13. `home/aliases.nix` (full) — Shell aliases
14. `home/packages/default.nix` (full) — Imports cli/dev/gui
15. `modules/desktop/sway/default.nix` (full) — System-level sway module with option `desktop.sway.enable`
16. `dotfiles/sway/config` (full) — Full sway config with keybindings, Nord colors, waybar/waybar/cliphist autostart
17. `dotfiles/waybar/config-sway.json` (full) — Waybar config for sway: modules, icons, playerctl, swaync
18. `dotfiles/waybar/style.css` (full) — Nord-themed waybar CSS
19. `dotfiles/swaync/config.json` (full) — Swaync notification center config
20. `references/hyprland.md` (full) — Hyprland NixOS/HM reference documentation
21. `AGENTS.md` (full) — Project guidelines, structure, conventions

## Key Code

### No Hyprland Module Exists
There is **no** `modules/desktop/hyprland/` directory. The project currently uses **Sway** exclusively. `references/hyprland.md` contains extracted wiki docs for future Hyprland migration.

### Module Pattern (custom options)
All home-manager programs follow this pattern — custom option under `programs.*`:
```nix
# home/programs/foot.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.foot-config;
in
{
  options.programs.foot-config = {
    enable = lib.mkEnableOption "Foot terminal configuration";
  };
  config = lib.mkIf cfg.enable {
    programs.foot = { ... };
  };
}
```

### System Module Pattern
```nix
# modules/desktop/sway/default.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.desktop.sway;
in
{
  options.desktop.sway = {
    enable = lib.mkEnableOption "Sway Wayland compositor";
  };
  config = lib.mkIf cfg.enable {
    programs.sway.enable = true;
    # ...
  };
}
```

### Host Imports Pattern
```nix
# hosts/panther/default.nix
imports = [
  ./hardware.nix ./networking.nix
  ../../modules/nvidia ../../modules/gaming ../../modules/virtualization
  ../../modules/desktop/sway ../../modules/services ../../modules/laptop
];
# Enable:
desktop.sway.enable = true;
# Home Manager:
home-manager.users.kx = import ../../home;
```

### Flake mkHost
```nix
mkHost = name: nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ./hosts/${name}
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops
  ];
};
```

### lib/default.nix Constants
```nix
username = "kx";
fullName = "Kevin Curtet";
userEmail = "kcurtet@gmail.com";
```

### Waybar Config (sway)
- Config: `dotfiles/waybar/config-sway.json` — uses `sway/workspaces`, `sway/window`
- Style: `dotfiles/waybar/style.css` — Nord theme, JetBrainsMono Nerd Font
- Launched from sway config: `exec waybar -c ~/.config/waybar/config-sway.json`

### Sway Config (dotfiles/sway/config)
- Symlinked via `mkOutOfStoreSymlink` from `home/programs/sway.nix`
- Autostarts: waybar, swaync, nm-applet, cliphist
- Uses: grim/slurp (screenshots), pamixer, brightnessctl, playerctl, swaylock, swayidle, wlogout, swaybg

## Architecture

```
flake.nix
  └─ mkHost "panther" → hosts/panther/default.nix
       ├─ imports modules/* (system-level: sway, nvidia, gaming, services...)
       ├─ home-manager.users.kx = import home/
       │    ├─ home/default.nix
       │    │    ├─ themes/nord.nix (GTK, bat, lazygit, tmux, ghostty theming)
       │    │    ├─ programs/ (custom options: foot-config, rofi-config, sway-config, git...)
       │    │    ├─ packages/ (cli, dev, gui)
       │    │    ├─ services/ (tailscale-systray)
       │    │    └─ aliases.nix
       │    └─ dotfiles/ (sway/config, waybar/*, rofi/nord.rasi, swaync/*)
       │         symlinked via mkOutOfStoreSymlink
       └─ lib/default.nix (username, helpers, theme imports)
            └─ lib/themes.nix (Nord palette)
```

**Two-level module split:**
- `modules/` = NixOS system-level (hardware, services, compositor install)
- `home/programs/` = Home Manager user-level (config, theming, packages)

**Config file strategy:** Large configs (sway, waybar, emacs) live in `dotfiles/` and are symlinked via `mkOutOfStoreSymlink` for edit-without-rebuild. Small configs (foot, git, bat) are declared inline in Nix.

## Start Here

1. **`home/default.nix`** — Central HM entry point, shows what's enabled and imported
2. **`home/programs/sway.nix`** — Pattern reference for creating a new WM home-manager module (custom option, symlink, packages)
3. **`modules/desktop/sway/default.nix`** — Pattern reference for creating a system-level desktop module
4. **`references/hyprland.md`** — Hyprland NixOS/HM reference for migration work
5. **`dotfiles/waybar/`** — Existing waybar config (will need hyprland-specific module names like `hyprland/workspaces`)
