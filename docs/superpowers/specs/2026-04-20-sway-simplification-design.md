# Sway Simplification Design

## Goal

Remove all desktop environments except Sway. Migrate all dotfiles to Nix-native Home Manager config. Eliminate dead code, duplicate terminals, and unused programs.

## What Gets Deleted

### Desktop modules
- `modules/desktop/gnome/`
- `modules/desktop/hyprland/`
- `modules/desktop/kde/`
- `modules/laptop/` (TLP disabled, unused)

### Home programs (dead/inactive)
- `home/programs/hyprland.nix`
- `home/programs/wezterm.nix`
- `home/programs/alacritty.nix`
- `home/programs/gnome-shell.nix`
- `home/programs/dunst.nix`
- `home/programs/gtk.nix`
- `home/programs/atuin.nix`
- `home/themes/nord.nix` (absorbed by lib)

### Dotfiles (entire directory)
- `dotfiles/sway/`
- `dotfiles/hypr/`
- `dotfiles/rofi/`
- `dotfiles/swaync/`
- `dotfiles/waybar/`
- `dotfiles/emacs/`
- `dotfiles/wallpapers/`

### From gui.nix packages
- ghostty, alacritty, wezterm (keep only foot)

### Waybar
- Remove entirely (swaybar replaces it)

## Final Repo Structure

```
.
├── flake.nix
├── hosts/panther/
│   ├── default.nix
│   ├── hardware.nix
│   └── networking.nix
├── modules/
│   ├── desktop/sway/        # only desktop
│   ├── gaming/
│   ├── nvidia/
│   ├── services/
│   └── virtualization/
├── home/
│   ├── default.nix          # imports + GTK/cursor
│   ├── aliases.nix
│   ├── programs/
│   │   ├── bat.nix
│   │   ├── direnv.nix
│   │   ├── emacs.nix        # NEW — inline from dotfiles/emacs
│   │   ├── foot.nix
│   │   ├── git.nix
│   │   ├── lazygit.nix
│   │   ├── rofi.nix         # Nord theme inline
│   │   ├── shells.nix       # bash only
│   │   ├── ssh.nix
│   │   ├── starship.nix
│   │   ├── sway.nix         # full config inline
│   │   ├── swaync.nix       # config inline
│   │   ├── television.nix
│   │   ├── tmux.nix
│   │   ├── yazi.nix
│   │   └── zellij.nix
│   ├── packages/
│   │   ├── cli.nix
│   │   └── dev.nix
│   └── services/
│       └── default.nix
├── lib/
│   └── default.nix          # username, email, helpers, Nord colors
├── scripts/
├── overlays/
├── pkgs/
└── secrets/
```

## Component Designs

### Sway (home/programs/sway.nix)

Native `wayland.windowManager.sway` HM config:

- `modifier = "Mod4"`, `terminal = "foot"`, `menu = "rofi -show drun"`
- `bars = [{ command = "swaybar"; }]` — swaybar, no waybar
- Wallpaper from Nix store via `pkgs.fetchurl` or local path
- Nord colors from `lib` (focused, unfocused, urgent, etc.)
- `gaps = { inner = 5; outer = 10; }`, `window.border = 2`
- Keybindings: Print for grim/slurp screenshots, standard Sway bindings
- Startup: swaync
- `seat seat0 xcursor_theme Nordzy-cursors 24` in extraConfig
- Packages: grim, slurp, swaybg, swaylock, wl-clipboard, cliphist

### Rofi (home/programs/rofi.nix)

Nord theme inline via `programs.rofi.theme` or `extraConfig`. No dotfiles.

### SwayNC (home/programs/swaync.nix)

Config JSON + CSS inline in HM. No dotfiles.

### Emacs (home/programs/emacs.nix)

New module. `init.el` and `early-init.el` content as strings or sourced from repo files. Emacs pgtk from dev.nix packages.

### Themes (single source)

`lib/default.nix` defines `nord` attrset with all colors. All programs import from lib. `home/themes/nord.nix` deleted. `lib/themes.nix` absorbed into `lib/default.nix`.

GTK theme set directly in `home/default.nix`:
- `gtk.theme.name = "Nordic"`
- `gtk.iconTheme.name = "Papirus-Dark"`
- `home.pointerCursor` with Nordzy-cursors

### Shells (home/programs/shells.nix)

Bash only. Remove fish and zsh config sections.

### gui.nix

Remove ghostty, alacritty, wezterm. Keep: brave, librewolf, chromium, telegram, discord, spotify, obsidian, libreoffice.

## Execution Order

### Deletions
1. `modules/desktop/{gnome,hyprland,kde}`
2. `dotfiles/` entire directory
3. `home/programs/{hyprland,wezterm,alacritty,gnome-shell,dunst,gtk,atuin}.nix`
4. `home/themes/nord.nix`
5. `modules/laptop/`

### Modifications
1. `lib/default.nix` — absorb `lib/themes.nix`, delete `lib/themes.nix`
2. `modules/desktop/sway/default.nix` — simplify packages
3. `home/programs/sway.nix` — rewrite with full inline config
4. `home/programs/rofi.nix` — Nord theme inline
5. `home/programs/swaync.nix` — config inline
6. New `home/programs/emacs.nix` — config from dotfiles
7. `home/programs/shells.nix` — bash only
8. `home/default.nix` — GTK, cursor, clean imports
9. `home/programs/default.nix` — only live imports
10. `home/packages/gui.nix` — remove extra terminals
11. `hosts/panther/default.nix` — remove dead imports

### Verification
- `statix check . && deadnix . && nixfmt-tree .`
- `sudo nixos-rebuild dry-build --flake .#panther`

## Decisions Made

| Decision | Choice |
|----------|--------|
| Terminal | foot only |
| Notifications | swaync |
| Launcher | rofi |
| Bar | swaybar |
| Screenshots | grim + slurp |
| Lock | swaylock |
| Wallpaper | swaybg, image in Nix store |
| Shell | bash only |
| Emacs | Nix-managed inline config |
| Theme source | lib/default.nix single source |
| Dotfiles | eliminated entirely |
