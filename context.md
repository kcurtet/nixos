# Code Context — Notification Configuration

## Files Retrieved

1. `home/programs/swaync.nix` (full, 35 lines) — SwayNC home-manager module (custom option `services.swaync-config`)
2. `home/programs/dunst.nix` (full, 32 lines) — Dunst home-manager module (custom option `services.dunst-config`)
3. `home/programs/default.nix` (full) — Imports list: **currently imports `swaync.nix`** (dunst.nix removed from imports)
4. `home/programs/hyprland.nix` (full) — Hyprland user config; no notification daemon enable here
5. `home/default.nix` (full) — Top-level home config; **no `services.swaync-config.enable = true` or `services.dunst-config.enable = true` found anywhere**
6. `modules/desktop/hyprland/default.nix` (lines 90-97) — System-level: installs `libnotify` only
7. `dotfiles/hypr/hyprland.conf` (line 30) — `exec-once = swaync` (autostart)
8. `dotfiles/swaync/config.json` (full) — SwayNC JSON config (position, timeouts, widgets)
9. `dotfiles/swaync/style.css` (lines 1-30) — Nord-themed SwayNC CSS (362 lines total)
10. `dotfiles/waybar/config.json` (lines 169-185) — Waybar `custom/swaync` module integration
11. `dotfiles/waybar/style.css` (lines 253-276) — Waybar SwayNC styling

## Key Code

### SwayNC module (`home/programs/swaync.nix`)
```nix
options.services.swaync-config = {
  enable = lib.mkEnableOption "SwayNotificationCenter configuration";
};
config = lib.mkIf cfg.enable {
  home = {
    packages = [ pkgs.swaynotificationcenter ];
    file = {
      ".config/swaync/config.json".source = mkOutOfStoreSymlink ".../dotfiles/swaync/config.json";
      ".config/swaync/style.css".source = mkOutOfStoreSymlink ".../dotfiles/swaync/style.css";
    };
  };
};
```

### Dunst module (`home/programs/dunst.nix`)
```nix
options.services.dunst-config = {
  enable = lib.mkEnableOption "Dunst notification daemon configuration";
};
config = lib.mkIf cfg.enable {
  services.dunst = {
    enable = true;
    settings = { global = { font = "JetBrainsMono Nerd Font 11"; ... }; ... };
  };
};
```

### Import switch (`home/programs/default.nix` line 9)
```nix
# Before (2026-03-25): ./dunst.nix
# After  (2026-04-08): ./swaync.nix
./swaync.nix
```

### Hyprland autostart (`dotfiles/hypr/hyprland.conf` line 30)
```
exec-once = swaync
```

### Waybar integration (`dotfiles/waybar/config.json`)
```json
"custom/swaync": {
  "exec": "swaync-client -sw",
  "on-click": "swaync-client -t -sw",
  "on-click-right": "swaync-client -d -sw",
  "return-type": "json"
}
```

## Architecture

### Migration: Dunst → SwayNC (commit `366da5e`, 2026-04-08)

| Aspect | Dunst (old) | SwayNC (current) |
|--------|-------------|-------------------|
| Home module | `home/programs/dunst.nix` | `home/programs/swaync.nix` |
| Import in default.nix | `./dunst.nix` | `./swaync.nix` |
| Config style | Inline Nix (services.dunst.settings) | Out-of-store symlink to `dotfiles/swaync/` |
| CSS theming | Via dunst settings | Full CSS file (Nord theme, 362 lines) |
| Waybar integration | `dunst-waybar.sh` script (deleted) | Native `swaync-client -sw` |
| Autostart | (via dunst service) | `exec-once = swaync` in hyprland.conf |
| Control center | None | GUI control center (right-click waybar) |
| DND toggle | None | Built-in (`swaync-client -d`) |

### Current state — ⚠️ Potential issue
- `swaync.nix` is imported but `services.swaync-config.enable` is **never set to `true`** anywhere in the codebase
- The module uses `lib.mkIf cfg.enable`, so the package + symlinks won't be installed via Home Manager
- SwayNC still runs because `exec-once = swaync` in hyprland.conf autostarts it, and `swaynotificationcenter` may be installed by other means or was installed before the migration
- **Dunst file still exists** at `home/programs/dunst.nix` but is not imported

### File dependency graph
```
home/default.nix
  └─ home/programs/default.nix
       └─ home/programs/swaync.nix (defines services.swaync-config option)
       └─ home/programs/dunst.nix (NOT imported — orphaned)

dotfiles/hypr/hyprland.conf → exec-once = swaync
dotfiles/swaync/config.json  ← symlinked by swaync.nix
dotfiles/swaync/style.css    ← symlinked by swaync.nix
dotfiles/waybar/config.json  → custom/swaync module (swaync-client)
dotfiles/waybar/style.css    → #custom-swaync styles
modules/desktop/hyprland/default.nix → libnotify (system package)
```

## Start Here

1. **`home/programs/swaync.nix`** — The active notification module. Note that `services.swaync-config.enable` needs to be set to `true` somewhere (e.g., in `home/default.nix` or per-host config).
2. **`home/programs/dunst.nix`** — Orphaned file from pre-migration. Safe to delete or keep as fallback.
3. **`dotfiles/swaync/`** — All SwayNC runtime config (JSON + CSS).
4. **`home/default.nix`** — Missing explicit `services.swaync-config.enable = true;` — likely a bug from the migration.
