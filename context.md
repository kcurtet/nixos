# NixOS Config Orphan/Unused Analysis

**Host:** panther | **Active desktop:** Sway + GDM | **Date:** 2026-04-20

---

## 1. Modules — Imported vs Orphaned

### Imported in `hosts/panther/default.nix` ✓
| Module | Status |
|--------|--------|
| `modules/nvidia` | ✓ Active (prime offload) |
| `modules/nvidia/specialisations` | ✓ Active |
| `modules/gaming` | ✓ Active (`gaming.enable = true`) |
| `modules/virtualization` | ✓ Active (docker + libvirtd) |
| `modules/desktop/sway` | ✓ Active (`desktop.sway.enable = true`) |
| `modules/services` | ✓ Active (syncthing, tailscale, tor, ollama, dnsmasq) |
| `modules/laptop` | ✓ Active (power mgmt) |

### NOT imported — completely dead code
| Module | Verdict |
|--------|---------|
| **`modules/desktop/gnome/`** | ❌ Dead. GDM/gnome-keyring configured directly in `hosts/panther/default.nix`, not via this module. The module is never imported. |
| **`modules/desktop/hyprland/`** | ❌ Dead. Previously used, now replaced by Sway. Never imported. |
| **`modules/desktop/kde/`** | ❌ Dead. Never imported. |

---

## 2. Home Programs — Enabled vs Dead

### Programs with custom `mkEnableOption` gates (require explicit `.enable = true`):

| Program File | Option | Where Set | Status |
|---|---|---|---|
| `sway.nix` | `programs.sway-config` | `home/default.nix:52` | ✓ Active |
| `foot.nix` | `programs.foot-config` | `home/default.nix:55` | ✓ Active |
| `rofi.nix` | `programs.rofi-config` | `home/default.nix:58` | ✓ Active |
| **`hyprland.nix`** | `programs.hyprland-config` | **Nowhere** | ❌ **DEAD — never enabled** |
| **`wezterm.nix`** | `programs.wezterm-config` | **Nowhere** | ❌ **DEAD — never enabled** |
| **`dunst.nix`** | `services.dunst-config` | **Nowhere** | ❌ **DEAD — never enabled** |
| **`swaync.nix`** | `services.swaync-config` | **Nowhere** | ❌ **DEAD — never enabled** |
| **`gtk.nix`** | `gtk-config` | **Nowhere** | ❌ **DEAD — never enabled** |

### Programs that ALWAYS enable (no gate — unconditional):

| Program File | Verdict |
|---|---|
| `alacritty.nix` | ⚠️ Always installs alacritty. Foot is configured as default terminal. **Unnecessary** — consider gating or removing. |
| `atuin.nix` | Explicitly `enable = false`. **Dead weight file** — imports for nothing. |
| `bat.nix` | ✓ Used (aliased to `k`) |
| `direnv.nix` | ✓ Used |
| `ghostty.nix` | ⚠️ Always installs ghostty. Not the default terminal. Also installed in `gui.nix` packages. |
| `git.nix` | ✓ Used |
| `gnome-shell.nix` | ⚠️ **Always enables** GNOME shell extensions + dconf. GNOME desktop is NOT active. Extensions like caffeine, gamemode-shell-extension, colorblind-filters — all dead. References wezterm as default terminal (which is also dead). |
| `lazygit.nix` | ✓ Used (aliased to `g`) |
| `shells.nix` | ✓ bash/fish/zsh all active |
| `ssh.nix` | ✓ Used |
| `starship.nix` | ✓ Active prompt |
| `television.nix` | ✓ Used (heavily via aliases) |
| `tmux.nix` | ✓ Used (sway keybind `$mod+Return` opens tmux) |
| `yazi.nix` | ✓ Used (aliased to `y`) |
| `zellij.nix` | ⚠️ Always installs. Not referenced in any keybind or alias. **Potentially unused** — tmux is the multiplexer. |

---

## 3. Package Review

### Duplicate packages (installed in multiple places):
| Package | Where | Notes |
|---|---|---|
| `ghostty` | `home/programs/ghostty.nix` + `home/packages/gui.nix` | Double-installed |
| `p7zip` | `modules/desktop/sway`, `home/packages/cli.nix` | System + user |
| `unzip` | `modules/desktop/sway`, `home/packages/cli.nix` | System + user |
| `zip` | `modules/desktop/sway`, `home/packages/cli.nix` | System + user |
| `wl-clipboard` | `hosts/panther/default.nix`, `home/programs/sway.nix`, `home/packages/cli.nix` | Triple-installed |
| `neovim` | `hosts/panther/default.nix` (system), `home/packages/dev.nix` (home) | Double-installed (overlay replaces system one with nixvim) |
| `nixfmt-tree` | `hosts/panther/default.nix` (system), `home/packages/cli.nix` (home) | Double-installed |
| `socat` | `home/packages/cli.nix` | Also used by hyprland monitor script (dead) |

### Questionable packages:
| Package | Location | Notes |
|---|---|---|
| `nyxt` | `home/packages/cli.nix` | Keyboard-driven browser. Has sway keybind (`$mod+Shift+b`). Niche. |
| `worktrunk` | `home/packages/cli.nix` | Work trunk tool. Shell integration exists. Low risk. |
| `castero` | `home/packages/cli.nix` | Podcast client. Not referenced anywhere else. |
| `cudatoolkit` | `home/packages/dev.nix` | CUDA toolkit. Machine has NVIDIA GPU — possibly needed for ollama, but ollama uses its own runtime. |
| `hmcl` | `home/packages/gui.nix` | Minecraft launcher. Gaming module active, so reasonable. |
| `google-cloud-sdk` | `home/packages/cli.nix` | Not referenced by any config. Dev tool — likely manual use. |

---

## 4. Dotfiles — Orphaned Entries

| Dotfile Dir | Symlinked From | Status |
|---|---|---|
| `emacs/` | `home/default.nix` | ✓ Active |
| `rofi/` | `home/programs/rofi.nix` (theme path) | ✓ Active |
| `sway/` | `home/programs/sway.nix` | ✓ Active |
| `wallpapers/` | `home/programs/sway.nix` | ✓ Active |
| **`hypr/`** | `home/programs/hyprland.nix` | ❌ **ORPHANED** — hyprland-config never enabled. All files dead: `hyprland.conf`, `hyprpaper.conf`, `hyprlock.conf`, `hypridle.conf`, `scripts/*` |
| **`swaync/`** | `home/programs/swaync.nix` | ❌ **ORPHANED** — swaync-config never enabled |
| **`waybar/`** | Not managed by Nix | ⚠️ **NO NIX MODULE** manages waybar. Sway config launches `waybar -c ~/.config/waybar/config-sway.json`. Waybar package is NOT installed by any nix config. Either installed outside nix or BROKEN. |

### Waybar config details:
- `waybar/config.json` — Uses **hyprland** modules (`hyprland/workspaces`, `hyprland/window`). Leftover from hyprland era. Dead.
- `waybar/config-sway.json` — Uses **sway** modules. Active. References rofi for app launcher ✓
- `waybar/style.css` — Shared theme. Likely still used.

### `hypr/scripts/gcal-waybar.sh`:
- Referenced in both waybar configs as calendar exec. This script lives in the hypr dotfiles dir but is used by sway's waybar too. **Should be moved** out of `hypr/` if hyprland is removed.

---

## 5. Rofi Usage

**Rofi IS actively used** despite being gated:
- `programs.rofi-config.enable = true` is set in `home/default.nix:58`
- Sway config: `$menu = rofi -show drun -show-icons -theme ~/.config/rofi/nord.rasi` (bound to `$mod+d`)
- Sway config: clipboard picker uses `rofi -dmenu`
- Waybar sway config: logo click launches rofi
- `gtk-icon-picker` script also uses rofi
- ✓ Fully active and wired in.

**However:** `wofi` is installed by `home/programs/sway.nix` but **never used**. Sway config uses rofi exclusively. **Remove wofi from sway.nix packages.**

---

## 6. Desktop Modules Status

| Desktop | Imported | Enabled | Active |
|---|---|---|---|
| **Sway** | ✓ | ✓ `desktop.sway.enable = true` | ✓ Primary |
| GNOME | ❌ | ❌ | ❌ Only GDM + gnome-keyring set directly in host config |
| Hyprland | ❌ | ❌ | ❌ Completely dead |
| KDE | ❌ | ❌ | ❌ Completely dead |

The GNOME module's functionality (GDM, keyring) is replicated directly in `hosts/panther/default.nix` rather than using the module. The gnome module is redundant for this host.

---

## 7. Dead Imports / References to Removed Things

| Issue | Location | Details |
|---|---|---|
| `waybar/config.json` references `hyprland/workspaces` | `dotfiles/waybar/config.json` | Dead — hyprland not active |
| `waybar/config.json` references `hyprland/window` | `dotfiles/waybar/config.json` | Dead |
| Waybar calendar calls `~/.config/hypr/scripts/gcal-waybar.sh` | Both waybar configs | Path depends on hypr dotfiles being symlinked, but hyprland-config is disabled so **this symlink is never created**. Calendar in waybar is likely **broken**. |
| `gnome-shell.nix` sets default terminal to `wezterm` | `home/programs/gnome-shell.nix:39` | Wezterm is never enabled. Dead reference. |
| `gnome-shell.nix` enables GNOME extensions | `home/programs/gnome-shell.nix` | GNOME desktop not active. Extensions dead. |
| `atuin.nix` imported but `enable = false` | `home/programs/default.nix` + `home/programs/atuin.nix` | Dead import — file does nothing. |

---

## 8. Scripts Usage

| Script | Installed | Used | Status |
|---|---|---|---|
| `emacs-up` | ✓ (via `scripts/default.nix`) | Manual CLI tool for emacs straight.el | ✓ Keep |
| `nboot` | ✓ | `sudo nixos-rebuild boot` wrapper | ✓ Keep |
| `nix-apply` | ✓ | Commit + rebuild wrapper | ✓ Keep (primary workflow) |
| `nix-up` | ✓ | `nix flake update` wrapper | ✓ Keep |
| **`gtk-icon-picker`** | ❌ NOT in `scripts/default.nix` | File exists in `scripts/` dir but **not exported** | ❌ **ORPHANED FILE** — not installed, not referenced |

---

## 9. Overlays

| Overlay | What | Status |
|---|---|---|
| neovim → nixvim | Replaces system neovim with nixvim flake build | ✓ Active and used |
| `pkgs.custom` | Imports `pkgs/default.nix` | ⚠️ **Empty** — `pkgs/default.nix` returns `{}` (empty attribute set). Dead overlay that does nothing. |

---

## 10. Flake Inputs Usage

| Input | Used Where | Status |
|---|---|---|
| `nixpkgs` | Everywhere | ✓ |
| `home-manager` | `flake.nix` outputs, imported as module | ✓ |
| `sops-nix` | `flake.nix` outputs, secrets in host config | ✓ |
| `nixvim` | Overlay (neovim replacement), devshell | ✓ |

**All flake inputs are used.** No dead inputs.

---

## Summary: Action Items by Priority

### 🔴 Broken (things that should work but don't)
1. **Waybar is NOT installed** — sway config launches it but no nix package provides it. Install `waybar` in `home/programs/sway.nix` or create a waybar module.
2. **Waybar calendar is broken** — calls `~/.config/hypr/scripts/gcal-waybar.sh` but that symlink is never created (hyprland-config disabled).
3. **SwayNC config symlinked but service not enabled** — `swaync` is launched in sway autostart but `services.swaync-config` is never set to true, so the config files are never symlinked.

### 🟡 Dead Code (remove to clean up)
4. **`modules/desktop/gnome/`** — never imported
5. **`modules/desktop/hyprland/`** — never imported
6. **`modules/desktop/kde/`** — never imported
7. **`home/programs/hyprland.nix`** — option never enabled
8. **`home/programs/wezterm.nix`** — option never enabled
9. **`home/programs/dunst.nix`** — option never enabled
10. **`home/programs/atuin.nix`** — explicitly disabled, dead import
11. **`dotfiles/hypr/`** — entire directory orphaned
12. **`dotfiles/waybar/config.json`** — hyprland-specific, dead
13. **`scripts/gtk-icon-picker`** — file not exported in default.nix
14. **`pkgs/default.nix`** — empty, overlay does nothing

### 🟠 Questionable (review and decide)
15. **`home/programs/alacritty.nix`** — always installs alacritty, but foot is default terminal
16. **`home/programs/gnome-shell.nix`** — always enables GNOME extensions, GNOME desktop not active
17. **`home/programs/gtk.nix`** — option never enabled (no GTK theming applied)
18. **`home/programs/zellij.nix`** — always installs, tmux is the configured multiplexer
19. **`home/programs/ghostty.nix`** — always installs + duplicated in gui.nix, not default terminal
20. **`wofi` in sway.nix** — installed but never used (rofi is used instead)
21. **`home/programs/swaync.nix`** — option never enabled, but sway launches swaync
22. **`gnome-shell.nix` references wezterm** as terminal — both dead

### 🔵 Duplicate Packages (consolidate)
23. `ghostty` — programs/ghostty.nix + packages/gui.nix
24. `wl-clipboard` — host config + sway.nix + cli.nix
25. `neovim` — host systemPackages + dev.nix
26. `nixfmt-tree` — host systemPackages + cli.nix
27. `p7zip`, `unzip`, `zip` — sway module + cli.nix
