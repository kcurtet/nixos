# Unified Navigation Keymap Design

**Date:** 2026-04-08
**Status:** Approved
**Scope:** Hyprland, tmux, nvim navigation consistency

## Problem

Navigation keys are inconsistent across the three main environments (Hyprland, tmux, nvim). Each uses different modifiers for similar actions, and there are conflicts (e.g., `Alt+hjkl` claimed by both tmux and nvim). The user has to think about which modifier to use depending on context.

## Principle

- **`Super`** = Hyprland (outer layer — window manager)
- **`Ctrl`** (via Caps Lock with keyd `overload(control, esc)`) = tmux + nvim (inner layer — terminal/editor)
- Same letters, same concepts, different modifier per environment
- keyd is the single source of truth for Caps Lock behavior (no changes needed)

## Navigation Map

| Action | Hyprland (`Super`) | tmux + nvim (`Ctrl`) |
|--------|-------------------|---------------------|
| Navigate | `Super + hjkl` | `Ctrl + hjkl` |
| Move entity | `Super + Shift + hjkl` | `Ctrl + Shift + hjkl` |
| Resize (mode) | `Super + R` → hjkl → Esc | tmux: `M-a + R` → hjkl → Esc, nvim: `leader + wr` → hjkl → Esc |

### Workspace / Space Navigation

| Action | Hyprland (`Super`) | tmux (`Ctrl`) | nvim |
|--------|-------------------|---------------|------|
| Go to space | `Super + 1-9` | `Ctrl + 1-9` | — |
| Move to space | `Super + Shift + 1-9` | — | — |
| Next/prev space | `Super + n/p` | `Ctrl + n/p` | — |
| Next/prev buffer | — | — | `;b` / `,b` |
| Next/prev tab | — | — | `;T` / `,T` |

### Line Movement (nvim only, unchanged)

- `Alt + j/k` — move lines up/down (normal + visual mode)
- `Alt + h/l` — visual mode indent (already configured, not changing)

## Components to Modify

### 1. keyd — No changes
Already configured correctly in `hosts/panther/default.nix`:
```
capslock = overload(control, esc)
esc = capslock
```

### 2. Hyprland — Minor changes
File: `dotfiles/hypr/hyprland.conf`

- `Super + hjkl` → already works for focus ✓
- `Super + Shift + hjkl` → already works for movewindow ✓
- Remove `Super + Alt + hjkl` resize binds
- Add resize submap: `Super + R` enters resize mode, `hjkl` resizes, `Esc` exits

### 3. tmux — Major rewrite
File: `home/programs/tmux.nix`

Changes:
- **Remove** `M-H/J/K/L` binds (conflicting duplicate: both resize and navigate)
- **Remove** `M-h/j/k/l` binds (replaced by Ctrl)
- **Remove** `C-M-h/j/k/l` swap binds (replaced by Ctrl+Shift)
- **Remove** prefix `h/j/k/l` binds (replaced by Ctrl without prefix)
- **Remove** prefix `H/J/K/L` resize binds (replaced by resize mode)
- **Remove** prefix `1-9` window binds (replaced by Ctrl)
- **Remove** `M-p/n` window navigation (replaced by Ctrl)
- **Add** `Ctrl + hjkl` without prefix → select-pane (via vim-tmux-navigator)
- **Add** `Ctrl + Shift + hjkl` without prefix → swap-pane
- **Add** `Ctrl + 1-9` without prefix → select-window
- **Add** `Ctrl + n/p` without prefix → next/previous window
- **Add** `M-a + R` → resize mode with hjkl, Esc exits
- Keep `M-a` prefix for all management actions (splits, kill, sessions, etc.)
- Keep vim-tmux-navigator plugin for seamless nvim↔tmux pane navigation

### 4. nvim — Update navigation binds
File: `config/keymaps.nix` (nixvim project)

Changes:
- **Replace** `M-hjkl` (Alt) window navigation with `C-hjkl` (Ctrl) — aligns with tmux
- `Alt + j/k` stays for line movement (unchanged)
- **Add** resize mode: `leader + wr` enters resize mode with hjkl, Esc exits
- vim-tmux-navigator config in `config/tmux-zellij.nix`: already uses `C-hjkl` ✓
- **Remove** `C-Up/Down/Left/Right` resize binds (replaced by resize mode)

## What Does NOT Change

- keyd configuration (already correct)
- Management actions: splits, kill, zoom, close (stays as-is)
- tmux prefix (`M-a`)
- nvim leader keys and leader-based bindings
- Buffer/tab navigation in nvim (`;b/,b`, `;T/,T`)
- All Hyprland app launchers and media keys

## Conflict Resolution

| Potential Conflict | Resolution |
|---|---|
| `Ctrl + hjkl` in tmux captured by nvim | vim-tmux-navigator handles pass-through intelligently |
| `Ctrl + R` redo in nvim | Resize uses `leader + wr` instead, not Ctrl |
| `Ctrl + n/p` in nvim insert mode | Only used in tmux for windows; nvim buffers use `;b/,b` |
| `Ctrl + 1-9` in terminal | tmux captures before terminal; no conflict |
| `Alt + j/k` in tmux | tmux won't use Alt for navigation anymore, passes through to nvim |
