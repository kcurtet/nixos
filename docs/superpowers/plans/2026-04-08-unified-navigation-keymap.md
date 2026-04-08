# Unified Navigation Keymap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify navigation across Hyprland, tmux, and nvim using `Super` for Hyprland and `Ctrl` (Caps Lock via keyd) for tmux+nvim.

**Architecture:** Three independent tasks — one per config file. Each produces a working, self-contained change. Hyprland gets a resize submap. tmux gets a full rewrite of navigation binds to use `Ctrl` without prefix. nvim replaces `Alt+hjkl` with `Ctrl+hjkl` and adds a resize mode.

**Tech Stack:** Hyprland config, tmux (Nix Home Manager), nixvim

**Spec:** `docs/superpowers/specs/2026-04-08-unified-navigation-keymap-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `dotfiles/hypr/hyprland.conf` | Modify | Replace resize binds with submap |
| `home/programs/tmux.nix` | Modify | Rewrite navigation binds to Ctrl, add resize mode |
| `~/code/projects/personal/nixvim/config/keymaps.nix` | Modify | Replace Alt+hjkl with Ctrl+hjkl, add resize mode, remove arrow resize |
| `~/code/projects/personal/nixvim/config/tmux-zellij.nix` | Verify | Already uses Ctrl+hjkl ✓ — no changes needed |

---

### Task 1: Hyprland — Resize submap

**Files:**
- Modify: `dotfiles/hypr/hyprland.conf`

- [ ] **Step 1: Remove old resize binds and add resize submap**

Replace the entire `# ── Resize (Super+Alt + hjkl / arrows, repeat on hold) ──` section with:

```hyprlang
# ── Resize mode (Super + R → hjkl → Esc) ──
bind = $mod, R, submap, resize

submap = resize
    binde = , H, resizeactive, -20 0
    binde = , L, resizeactive, 20 0
    binde = , K, resizeactive, 0 -20
    binde = , J, resizeactive, 0 20
    binde = , left, resizeactive, -20 0
    binde = , right, resizeactive, 20 0
    binde = , up, resizeactive, 0 -20
    binde = , down, resizeactive, 0 20
    bind = , Escape, submap, reset
    bind = , Return, submap, reset
submap = reset
```

- [ ] **Step 2: Commit**

```bash
cd /home/kx/system/nixos-config
git add dotfiles/hypr/hyprland.conf
git commit -m "hyprland: replace Super+Alt resize with Super+R resize submap"
```

---

### Task 2: tmux — Rewrite navigation to Ctrl

**Files:**
- Modify: `home/programs/tmux.nix`

- [ ] **Step 1: Replace navigation section in extraConfig**

Remove these sections entirely (they are being replaced):
- `# ─── Navegación entre paneles (vim hjkl) ──` (all 10 binds including M-H/J/K/L)
- `# ─── Redimensionar paneles (HJKL) ──` (all 8 binds including M-H/J/K/L)
- `# ─── Mover paneles (HJKL) ──` (4 C-M binds)
- `# ─── Navegación entre ventanas ──` (all window binds: 1-9, <>, M-p, M-n, C-0)

Replace with:

```
      # ─── Navegación entre paneles (Ctrl + hjkl, sin prefix) ─────────
      # vim-tmux-navigator handles Ctrl+hjkl automatically

      # ─── Mover paneles (Ctrl+Shift + hjkl, sin prefix) ─────────────
      bind -n C-H swap-pane -s '{left-of}'
      bind -n C-J swap-pane -D
      bind -n C-K swap-pane -U
      bind -n C-L swap-pane -s '{right-of}'

      # ─── Navegación entre ventanas (Ctrl + 1-9 / n/p, sin prefix) ──
      bind -n C-1 select-window -t 1
      bind -n C-2 select-window -t 2
      bind -n C-3 select-window -t 3
      bind -n C-4 select-window -t 4
      bind -n C-5 select-window -t 5
      bind -n C-6 select-window -t 6
      bind -n C-7 select-window -t 7
      bind -n C-8 select-window -t 8
      bind -n C-9 select-window -t 9
      bind -n -r C-n next-window
      bind -n -r C-p previous-window

      # ─── Modo resize (prefix + R → hjkl → Esc) ─────────────────────
      bind R switch-client -T resize
      bind -T resize h resize-pane -L 5
      bind -T resize j resize-pane -D 5
      bind -T resize k resize-pane -U 5
      bind -T resize l resize-pane -R 5
      bind -T resize H resize-pane -L 10
      bind -T resize J resize-pane -D 10
      bind -T resize K resize-pane -U 10
      bind -T resize L resize-pane -R 10
      bind -T resize Escape switch-client -T root
      bind -T resize q switch-client -T root
```

- [ ] **Step 2: Verify the remaining sections are untouched**

Confirm these sections remain exactly as-is:
- `# ─── General ──`
- `# ─── Recargar config ──`
- `# ─── Sessiones ──`
- `# ─── Splits ──`
- `# ─── Gestión de paneles ──`
- `# ─── Modo copia ──`
- `# ─── Unbind keys ──`
- `# ─── Barra de estado ──`

- [ ] **Step 3: Commit**

```bash
cd /home/kx/system/nixos-config
git add home/programs/tmux.nix
git commit -m "tmux: unify navigation to Ctrl+hjkl, add Ctrl+1-9 windows, prefix+R resize mode"
```

---

### Task 3: nvim — Replace Alt navigation with Ctrl, add resize mode

**Files:**
- Modify: `~/code/projects/personal/nixvim/config/keymaps.nix`

- [ ] **Step 1: Remove old Alt+hjkl window navigation and arrow resize binds**

Delete these 8 keymap entries entirely:
- The 4 `<M-h/j/k/l>` "Navigate left/down/up/right" entries
- The 4 `<C-Up/Down/Left/Right>` "Increase/Decrease window height/width" entries

- [ ] **Step 2: Add Ctrl+hjkl navigation (handled by vim-tmux-navigator)**

The `tmux-navigator` plugin in `tmux-zellij.nix` already maps `<C-h/j/k/l>`. No new keymaps needed — just confirm the plugin config is correct (it already is with `<C-h/j/k/l>`).

However, add `Ctrl+Shift+hjkl` for moving/swapping splits within nvim (mirror of tmux swap-pane):

```nix
    # Window navigation (Ctrl+hjkl handled by vim-tmux-navigator)
    # Window swap (Ctrl+Shift+hjkl)
    {
      key = "<C-H>";
      mode = "n";
      options = {
        silent = true;
        desc = "Move window left";
      };
      action = "<C-w>H";
    }
    {
      key = "<C-J>";
      mode = "n";
      options = {
        silent = true;
        desc = "Move window down";
      };
      action = "<C-w>J";
    }
    {
      key = "<C-K>";
      mode = "n";
      options = {
        silent = true;
        desc = "Move window up";
      };
      action = "<C-w>K";
    }
    {
      key = "<C-L>";
      mode = "n";
      options = {
        silent = true;
        desc = "Move window right";
      };
      action = "<C-w>L";
    }
```

Insert these after the old window navigation section (where the `<M-h/j/k/l>` entries were).

- [ ] **Step 3: Replace `<leader>wr` resize with resize mode**

Change the existing `<leader>wr` "Rotate windows" entry (which is a niche command) to be a resize mode. Since this changes the meaning of `<leader>wr`, update desc:

```nix
    {
      key = "<leader>wr";
      mode = "n";
      options = {
        silent = true;
        desc = "Enter resize mode";
      };
      action.__raw = "function() vim.ui.input({prompt = 'Resize mode: h/j/k/l resize, Enter/Esc to exit'}, function() end) end";
    }
```

Actually, nvim doesn't have native submaps like Hyprland/tmux. Instead, use a simpler approach — `<leader>wr` enters a buffer-local resize mode using a recursive mapping:

```nix
    {
      key = "<leader>wr";
      mode = "n";
      options = {
        silent = true;
        desc = "Enter resize mode (hjkl to resize, q/Esc to exit)";
      };
      action.__raw = ''
        function()
          local opts = { buffer = true, silent = true }
          local rhs = function(step)
            return function()
              -- step is a function that takes a count
            end
          end
          vim.keymap.set('n', 'h', '<cmd>vertical resize -2<CR>', opts)
          vim.keymap.set('n', 'l', '<cmd>vertical resize +2<CR>', opts)
          vim.keymap.set('n', 'j', '<cmd>resize +2<CR>', opts)
          vim.keymap.set('n', 'k', '<cmd>resize -2<CR>', opts)
          vim.keymap.set('n', 'H', '<cmd>vertical resize -5<CR>', opts)
          vim.keymap.set('n', 'L', '<cmd>vertical resize +5<CR>', opts)
          vim.keymap.set('n', 'J', '<cmd>resize +5<CR>', opts)
          vim.keymap.set('n', 'K', '<cmd>resize -5<CR>', opts)
          vim.keymap.set('n', 'q', function()
            vim.keymap.del('n', 'h', { buffer = true })
            vim.keymap.del('n', 'l', { buffer = true })
            vim.keymap.del('n', 'j', { buffer = true })
            vim.keymap.del('n', 'k', { buffer = true })
            vim.keymap.del('n', 'H', { buffer = true })
            vim.keymap.del('n', 'L', { buffer = true })
            vim.keymap.del('n', 'J', { buffer = true })
            vim.keymap.del('n', 'K', { buffer = true })
            vim.keymap.del('n', 'q', { buffer = true })
            vim.keymap.del('n', '<Esc>', { buffer = true })
            print('Exited resize mode')
          end, opts)
          vim.keymap.set('n', '<Esc>', function()
            vim.keymap.del('n', 'h', { buffer = true })
            vim.keymap.del('n', 'l', { buffer = true })
            vim.keymap.del('n', 'j', { buffer = true })
            vim.keymap.del('n', 'k', { buffer = true })
            vim.keymap.del('n', 'H', { buffer = true })
            vim.keymap.del('n', 'L', { buffer = true })
            vim.keymap.del('n', 'J', { buffer = true })
            vim.keymap.del('n', 'K', { buffer = true })
            vim.keymap.del('n', 'q', { buffer = true })
            vim.keymap.del('n', '<Esc>', { buffer = true })
            print('Exited resize mode')
          end, opts)
          print('Resize mode: hjkl to resize, q/Esc to exit')
        end
      '';
    }
```

- [ ] **Step 4: Commit**

```bash
cd /home/kx/code/projects/personal/nixvim
git add config/keymaps.nix
git commit -m "nvim: unify navigation to Ctrl+hjkl, add resize mode, remove Alt nav"
```

---

### Task 4: Verify — Build and test

- [ ] **Step 1: Verify NixOS config builds**

```bash
cd /home/kx/system/nixos-config
sudo nixos-rebuild dry-build --flake .#panther
```

Expected: build succeeds without errors.

- [ ] **Step 2: Verify nixvim config builds**

```bash
cd /home/kx/code/projects/personal/nixvim
nix build
```

Expected: build succeeds without errors.

- [ ] **Step 3: Final commit (if any fixes were needed)**

```bash
git add -A
git commit -m "fix: resolve build issues from navigation keymap changes"
```
