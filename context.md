# Code Context

## Files Retrieved

1. `flake.nix` — Flake entry: inputs (nixpkgs, nixvim, home-manager, sops-nix), outputs (mkHost helper, panther host, formatter, devShell)
2. `hosts/panther/default.nix` — Main host config: imports modules, sets up user, NVIDIA, gaming, virtualization, services, Home Manager
3. `hosts/panther/hardware.nix` — Hardware scan: zen kernel, Intel+NVIDIA, ext4+btrfs+swap, zram, sysctl tuning
4. `hosts/panther/networking.nix` — Hostname, NetworkManager, firewall, extraHosts for arr stack
5. `modules/desktop/gnome/default.nix` — GNOME module (option `desktop.gnome`, GDM, keyring, xkb)
6. `modules/desktop/hyprland/default.nix` — Hyprland module (option `desktop.hyprland-wayland`, monitor daemon, portals, system pkgs)
7. `modules/desktop/sway/default.nix` — **ACTIVE** Sway module (option `desktop.sway`, session env vars, wlr portal, foot terminal)
8. `modules/desktop/kde/default.nix` — KDE Plasma 6 module (option `desktop.kde`, minimal)
9. `modules/nvidia/default.nix` — NVIDIA module (option `hardware.nvidiaConfig`, PRIME offload, modesetting)
10. `modules/nvidia/specialisations.nix` — Boot profiles: on-the-go (sync), disable-intel, disable-nvidia
11. `modules/gaming/default.nix` — Gaming module: Steam, GameMode, Gamescope, Wine, mangohud
12. `modules/virtualization/default.nix` — Docker + libvirtd module
13. `modules/services/default.nix` — Services module: syncthing, tailscale, tor, flatpak, openssh, ollama, dnsmasq
14. `modules/laptop/default.nix` — TLP power management module (disabled in host)
15. `home/default.nix` — Home Manager entry: imports themes, programs, packages, services, aliases; sets up emacs symlinks, PATH, session vars
16. `home/aliases.nix` — Shell aliases: git, eza, tv channels, pi shortcuts
17. `home/packages/default.nix` — Package index: cli.nix, dev.nix, gui.nix
18. `home/packages/cli.nix` — CLI tools: imagemagick, eza, btop, fd, jq, rg, gh, ffmpeg, nyxt, etc.
19. `home/packages/dev.nix` — Dev tools: emacs-pgtk+vterm+treesitter, vscode-fhs, nodejs, python, rust, lua, fennel, CUDA
20. `home/packages/gui.nix` — GUI apps: brave, librewolf, chromium, telegram, discord, spotify, obsidian, libreoffice
21. `home/services/default.nix` — tailscale-systray only
22. `home/themes/nord.nix` — Nord theme: dconf dark, lazygit colors, bat, zellij, tmux, ghostty themes
23. `home/programs/default.nix` — Program index: 21 modules imported
24. `home/programs/sway.nix` — Sway HM config: symlinks dotfiles/sway/config, installs grim/slurp/wl-clipboard/swaybg/wofi/wlogout etc
25. `home/programs/hyprland.nix` — Hyprland HM config: symlinks dotfiles/hypr/*, installs hyprlock/hypridle/hyprpaper/hyprpicker etc
26. `home/programs/foot.nix` — Foot terminal: JetBrainsMono 14, Nord colors, dpi-aware
27. `home/programs/ghostty.nix` — Ghostty terminal: JetBrainsMono 14, bash login shell
28. `home/programs/alacritty.nix` — Alacritty terminal: full Nord theme from lib/themes.nix, JetBrainsMono 14
29. `home/programs/wezterm.nix` — WezTerm terminal: minimal no-chrome, Nord colors, no tabs
30. `home/programs/rofi.nix` — Rofi launcher: uses dotfiles/rofi/nord.rasi theme
31. `home/programs/gnome-shell.nix` — GNOME extensions + dconf settings (Nordic theme, wezterm default terminal)
32. `home/programs/gtk.nix` — GTK theme: Nordic, Papirus-Dark icons (option `gtk-config`, NOT imported!)
33. `home/programs/dunst.nix` — Dunst notifications: Nord colors (option `services.dunst-config`, NOT imported!)
34. `home/programs/swaync.nix` — SwayNC notifications: symlinks dotfiles/swaync/* (option `services.swaync-config`, NOT explicitly imported but works via sway config autostart)
35. `home/programs/git.nix` — Git + Delta: colorblind-friendly Nord theme, side-by-side diffs
36. `home/programs/shells.nix` — Bash/Fish/Zsh: SOPS env vars, zoxide, helper scripts (clip, E, b, S)
37. `home/programs/starship.nix` — Starship prompt: minimal config
38. `home/programs/ssh.nix` — SSH: minimal config, TERM=xterm-256color
39. `home/programs/tmux.nix` — Tmux: C-a prefix, vi mode, Nord status bar, plugins (resurrect, continuum, vim-tmux-navigator)
40. `home/programs/yazi.nix` — Yazi file manager: bash/fish/zsh integration
41. `home/programs/zellij.nix` — Zellij: Nord theme, dev layout, custom keybinds
42. `home/programs/lazygit.nix` — LazyGit: enabled, theme in themes/nord.nix
43. `home/programs/atuin.nix` — Atuin: **disabled** (enable = false)
44. `home/programs/bat.nix` — Bat: Nord theme
45. `home/programs/direnv.nix` — Direnv + nix-direnv
46. `home/programs/television.nix` — Television fuzzy finder: extensive config with custom channels (nix-options, nix-store, nix-flake-inputs, ollama-models, hcloud-servers, syncthing-folders, nixos-config, nixos-generations)
47. `lib/default.nix` — Library: exposes themes (colors, gtk, cursor, lazygit), username, userEmail, mkLazyGitTheme, mkHost helper
48. `lib/themes.nix` — Nord color palette (n0-n15), GTK/cursor/lazygit theme definitions
49. `scripts/default.nix` — Shell scripts: emacs-up, nboot, nix-apply, nix-up
50. `overlays/default.nix` — Overlays: nixvim neovim replacement, custom pkgs
51. `pkgs/default.nix` — Custom packages: empty `{}`
52. `dotfiles/sway/config` — **ACTIVE** Sway config: Mod4, foot, rofi, swaybg, waybar (config-sway.json), swaync, cliphist, Nord colors, keybindings, window rules
53. `dotfiles/waybar/config.json` — Waybar config for Hyprland: hyprland/workspaces, hyprland/window modules
54. `dotfiles/waybar/config-sway.json` — Waybar config for Sway: sway/workspaces, sway/window modules
55. `dotfiles/waybar/style.css` — Waybar Nord theme: transparent bg, frost accents
56. `dotfiles/rofi/nord.rasi` — Rofi Nord theme
57. `dotfiles/hypr/hyprland.conf` — Hyprland config (symlinked, not read but exists)
58. `dotfiles/hypr/hypridle.conf` — Hypridle config (symlinked)
59. `dotfiles/hypr/hyprlock.conf` — Hyprlock config (symlinked)
60. `dotfiles/hypr/hyprpaper.conf` — Hyprpaper config (symlinked)
61. `dotfiles/hypr/scripts/` — alarm.sh, gcal-waybar.sh, keybinds.sh, powermenu.sh
62. `dotfiles/emacs/` — early-init.el, init.el (symlinked out-of-store)
63. `dotfiles/swaync/config.json` + `style.css` — SwayNC config (symlinked)
64. `.sops.yaml` — SOPS age key config for secrets encryption
65. `secrets/secrets.yaml` — Encrypted secrets (zai_api_key, brave_api_key, npm-token)
66. `.gitignore` — Ignores decrypted secrets, result, editor files, direnv, .beads

## Key Code

### Active Desktop: Sway
```
# hosts/panther/default.nix line ~112
../../modules/desktop/sway     # ← ACTIVE
desktop.sway.enable = true;    # ← ENABLED
```

### Home Manager Programs (all imported unconditionally)
```nix
# home/programs/default.nix
imports = [
  ./atuin.nix       # enable = false
  ./bat.nix         # Nord theme
  ./direnv.nix
  ./swaync.nix      # services.swaync-config (needs explicit enable)
  ./foot.nix        # programs.foot-config ← enabled in home/default.nix
  ./ghostty.nix     # always enabled
  ./git.nix
  ./gnome-shell.nix # always enabled (gnome extensions)
  ./gtk.nix         # gtk-config option (NOT enabled in home/default.nix)
  ./hyprland.nix    # programs.hyprland-config (NOT enabled)
  ./alacritty.nix   # always enabled
  ./lazygit.nix
  ./rofi.nix        # programs.rofi-config ← enabled in home/default.nix
  ./shells.nix
  ./ssh.nix
  ./starship.nix
  ./sway.nix        # programs.sway-config ← enabled in home/default.nix
  ./television.nix
  ./tmux.nix
  ./wezterm.nix     # programs.wezterm-config (NOT enabled)
  ./yazi.nix
  ./zellij.nix
];
```

### Home Default Enables
```nix
# home/default.nix
programs.sway-config.enable = true;
programs.foot-config.enable = true;
programs.rofi-config.enable = true;
# gnome-shell always active (no enable option)
# ghostty always active (no enable option)
# alacritty always active (no enable option)
```

### Theme System
```
lib/themes.nix → Nord colors n0-n15, GTK name "Nordic", cursor "Nordzy-cursors"
home/themes/nord.nix → duplicates colors, applies to lazygit/bat/zellij/tmux/ghostty
```

### Terminal Emulators (5 configured!)
1. **foot** — Sway default (`$term`), enabled
2. **ghostty** — always installed+configured, listed in gui.nix too
3. **alacritty** — always installed+configured
4. **wezterm** — option exists but NOT enabled (gnome-shell dconf sets it as GNOME default terminal!)
5. **foot** — set as xdg terminal-exec default

### Sway Config (dotfiles/sway/config)
- Mod4 (Super), foot terminal, rofi launcher
- waybar with config-sway.json, swaync autostart
- cliphist for clipboard, grim/slurp for screenshots
- Nord colors, gaps 5/10, pixel borders

## Architecture

```
flake.nix
├── inputs: nixpkgs, nixvim, home-manager, sops-nix
├── outputs
│   ├── nixosConfigurations.panther = mkHost "panther"
│   │   └── hosts/panther/default.nix
│   │       ├── hardware.nix (zen kernel, NVIDIA, zram)
│   │       ├── networking.nix (NetworkManager, firewall)
│   │       ├── modules/nvidia (PRIME offload)
│   │       ├── modules/nvidia/specialisations (3 boot profiles)
│   │       ├── modules/gaming (Steam, GameMode)
│   │       ├── modules/virtualization (Docker, libvirtd)
│   │       ├── modules/desktop/sway ← ACTIVE
│   │       ├── modules/services (syncthing, tailscale, tor, ollama, dnsmasq)
│   │       ├── modules/laptop (TLP, disabled)
│   │       ├── home-manager.users.kx → home/default.nix
│   │       │   ├── themes/nord.nix
│   │       │   ├── programs/ (21 modules)
│   │       │   │   ├── sway.nix → dotfiles/sway/config
│   │       │   │   ├── foot.nix, ghostty.nix, alacritty.nix, wezterm.nix
│   │       │   │   ├── git.nix (delta), shells.nix (bash/fish/zsh)
│   │       │   │   ├── tmux.nix, zellij.nix, starship.nix
│   │       │   │   ├── television.nix (massive custom channels)
│   │       │   │   └── ... more
│   │       │   ├── packages/ (cli, dev, gui)
│   │       │   ├── services/ (tailscale-systray)
│   │       │   └── aliases.nix
│   │       └── sops secrets (zai_api_key, brave_api_key)
│   ├── formatter (nixfmt-tree)
│   └── devShells (nixd, nixfmt-tree, statix, deadnix, sops, nixvim)
├── lib/ (themes, mkHost, user constants)
├── scripts/ (emacs-up, nboot, nix-apply, nix-up)
├── overlays/ (nixvim neovim, custom pkgs)
├── pkgs/ (empty)
└── dotfiles/ (NOT managed by Nix, symlinked out-of-store)
    ├── sway/config
    ├── hypr/ (hyprland.conf, hypridle, hyprlock, hyprpaper, scripts/)
    ├── waybar/ (config.json, config-sway.json, style.css)
    ├── rofi/nord.rasi
    ├── swaync/ (config.json, style.css)
    ├── emacs/ (early-init.el, init.el)
    └── wallpapers/merry-hd.jpg
```

## Simplification Opportunities

### Dead/Unused Code
- `modules/desktop/gnome/` — not imported by any host
- `modules/desktop/hyprland/` — not imported by any host (was previous desktop)
- `modules/desktop/kde/` — not imported by any host
- `home/programs/hyprland.nix` — `programs.hyprland-config` never enabled
- `home/programs/wezterm.nix` — `programs.wezterm-config` never enabled
- `home/programs/gnome-shell.nix` — gnome extensions always active, but running Sway not GNOME
- `home/programs/dunst.nix` — `services.dunst-config` never enabled (swaync used instead)
- `home/programs/gtk.nix` — `gtk-config` never enabled
- `dotfiles/hypr/` — entire directory unused
- `dotfiles/waybar/config.json` — Hyprland waybar config, unused
- `home/programs/atuin.nix` — explicitly disabled
- `lib/themes.nix` lazygit/cursor functions — imported but theme also duplicated in `home/themes/nord.nix`

### Duplicated/Redundant
- Nord colors defined in 3 places: `lib/themes.nix`, `home/themes/nord.nix`, `dotfiles/sway/config`
- 5 terminal emulators configured (foot, ghostty, alacritty, wezterm, + foot in system pkgs)
- ghostty installed both in system packages (hyprland module) AND home packages
- `gtk.nix` option `gtk-config` exists but gnome-shell.nix also sets GTK theme via dconf
- `home/themes/nord.nix` duplicates `lib/themes.nix` colors inline

### Structural Issues
- Programs imported unconditionally in `home/programs/default.nix` — should be conditional on enable flags
- `home/default.nix` only enables 3 of 21+ program modules; rest are either always-on (no option) or dead
- `lib/default.nix` mkHost helper unused (flake.nix has its own)
- `pkgs/default.nix` empty

## Start Here

**`hosts/panther/default.nix`** — Single source of truth for what's active. Currently imports `modules/desktop/sway`, enables `desktop.sway`, and wires everything together. Read this first to understand what modules are active, then trace imports.

**`home/default.nix`** — Second priority. Shows which HM programs are enabled vs just imported.
