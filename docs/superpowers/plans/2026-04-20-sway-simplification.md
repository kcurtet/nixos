# Sway Simplification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all desktops except Sway, migrate all dotfiles to Nix-native HM config, eliminate dead code.

**Architecture:** Absorb themes into lib, rewrite sway/rofi/swaync as native HM modules with inline config, create emacs HM module from dotfiles, delete everything dead.

**Tech Stack:** NixOS, Home Manager, Sway, Nix

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Delete | `lib/themes.nix` | Absorbed by lib/default.nix |
| Delete | `modules/desktop/gnome/` | Dead desktop |
| Delete | `modules/desktop/hyprland/` | Dead desktop |
| Delete | `modules/desktop/kde/` | Dead desktop |
| Delete | `modules/laptop/` | TLP disabled |
| Delete | `dotfiles/` | All migrated to Nix |
| Delete | `home/programs/hyprland.nix` | Dead |
| Delete | `home/programs/wezterm.nix` | Dead |
| Delete | `home/programs/alacritty.nix` | Dead |
| Delete | `home/programs/gnome-shell.nix` | Dead |
| Delete | `home/programs/dunst.nix` | Dead |
| Delete | `home/programs/gtk.nix` | Dead |
| Delete | `home/programs/atuin.nix` | Dead |
| Delete | `home/programs/ghostty.nix` | Dead |
| Delete | `home/themes/nord.nix` | Absorbed by lib |
| Modify | `lib/default.nix` | Absorb themes, single source of Nord colors |
| Modify | `modules/desktop/sway/default.nix` | Remove wofi, simplify |
| Modify | `home/programs/sway.nix` | Full inline config, no dotfiles |
| Modify | `home/programs/rofi.nix` | Nord theme inline |
| Modify | `home/programs/swaync.nix` | Config inline |
| Modify | `home/programs/shells.nix` | Bash only |
| Modify | `home/programs/foot.nix` | Colors from lib |
| Modify | `home/programs/bat.nix` | Keep as-is (already Nord) |
| Modify | `home/programs/tmux.nix` | Nord plugin via themes from lib |
| Modify | `home/programs/lazygit.nix` | Theme from lib |
| Modify | `home/programs/zellij.nix` | Theme from lib |
| Modify | `home/programs/default.nix` | Only live imports |
| Modify | `home/default.nix` | GTK, cursor, clean imports, emacs |
| Modify | `home/packages/gui.nix` | Remove ghostty |
| Modify | `hosts/panther/default.nix` | Remove dead imports, laptop |
| Create | `home/programs/emacs.nix` | Config from dotfiles |
| Create | `home/emacs/early-init.el` | Emacs early-init content |
| Create | `home/emacs/init.el` | Emacs init content |
| Create | `home/wallpapers/merry-hd.jpg` | Wallpaper for Nix store |

---

### Task 1: Absorb themes into lib

**Files:**
- Modify: `lib/default.nix`
- Delete: `lib/themes.nix`

- [ ] **Step 1: Rewrite lib/default.nix absorbing lib/themes.nix**

```nix
# ============================================================================
# Library Functions and Constants
# ============================================================================
{ lib }:

let
  # ============================================================================
  # Nord Color Palette
  # ============================================================================
  colors = {
    # Polar Night
    n0 = "#2e3440";
    n1 = "#3b4252";
    n2 = "#434c5e";
    n3 = "#4c566a";

    # Snow Storm
    n4 = "#d8dee9";
    n5 = "#e5e9f0";
    n6 = "#eceff4";

    # Frost
    n7 = "#8fbcbb";
    n8 = "#88c0d0";
    n9 = "#81a1c1";
    n10 = "#5e81ac";

    # Aurora
    n11 = "#bf616a";
    n12 = "#d08770";
    n13 = "#ebcb8b";
    n14 = "#a3be8c";
    n15 = "#b48ead";
  };

  # GTK theme
  gtk = "Nordic";
  gtkPackage = "nordic";

  # Cursor theme
  cursor = {
    name = "Nordzy-cursors";
    package = "nordzy-cursor-theme";
  };

  # LazyGit theme generator
  mkLazyGitTheme = colors: {
    activeBorderColor = [
      colors.n8
      "bold"
    ];
    inactiveBorderColor = [ colors.n3 ];
    searchingActiveBorderColor = [
      colors.n9
      "bold"
    ];
    selectedLineBgColor = [ colors.n1 ];
    selectedRangeBgColor = [ colors.n2 ];
    cherryPickedCommitBgColor = [ colors.n2 ];
    cherryPickedCommitFgColor = [ colors.n8 ];
    markedBaseCommitBgColor = [ colors.n15 ];
    markedBaseCommitFgColor = [ colors.n0 ];
    optionsTextColor = [ colors.n8 ];
    defaultFgColor = [ colors.n4 ];
    unstagedChangesColor = [ colors.n11 ];
    stagedChangesColor = [ colors.n14 ];
    untrackedChangesColor = [ colors.n13 ];
    conflictedChangesColor = [ colors.n11 ];
    remoteBranchColor = [ colors.n15 ];
    localBranchColor = [ colors.n14 ];
    tagColor = [ colors.n13 ];
    upstreamColor = [ colors.n10 ];
    reflogCommitColor = [ colors.n12 ];
    authorColor = [ colors.n7 ];
    commitHashColor = [ colors.n9 ];
  };

  # Helper to create a host configuration
  mkHost =
    {
      name,
      system ? "x86_64-linux",
      extraModules ? [ ],
    }:
    { pkgs, inputs, ... }@args:
    lib.nixosSystem {
      inherit system;
      specialArgs = args // {
        inherit inputs;
        lib = lib // (import ./. { inherit lib; });
      };
      modules = extraModules;
    };
in
{
  inherit colors gtk gtkPackage cursor mkLazyGitTheme;

  # User constants
  username = "kx";
  fullName = "Kevin Curtet";
  userEmail = "kcurtet@gmail.com";
}
```

- [ ] **Step 2: Delete lib/themes.nix**

```bash
rm lib/themes.nix
```

- [ ] **Step 3: Verify syntax**

```bash
nix-instantiate --parse lib/default.nix > /dev/null
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "refactor: absorb themes.nix into lib/default.nix"
```

---

### Task 2: Delete dead modules

**Files:**
- Delete: `modules/desktop/gnome/`
- Delete: `modules/desktop/hyprland/`
- Delete: `modules/desktop/kde/`
- Delete: `modules/laptop/`

- [ ] **Step 1: Delete directories**

```bash
rm -rf modules/desktop/gnome modules/desktop/hyprland modules/desktop/kde modules/laptop
```

- [ ] **Step 2: Verify only sway remains**

```bash
ls modules/desktop/
```

Expected: only `sway`.

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "remove: delete gnome, hyprland, kde, laptop modules"
```

---

### Task 3: Delete dead home programs

**Files:**
- Delete: `home/programs/hyprland.nix`
- Delete: `home/programs/wezterm.nix`
- Delete: `home/programs/alacritty.nix`
- Delete: `home/programs/gnome-shell.nix`
- Delete: `home/programs/dunst.nix`
- Delete: `home/programs/gtk.nix`
- Delete: `home/programs/atuin.nix`
- Delete: `home/programs/ghostty.nix`

- [ ] **Step 1: Delete files**

```bash
rm home/programs/hyprland.nix home/programs/wezterm.nix home/programs/alacritty.nix home/programs/gnome-shell.nix home/programs/dunst.nix home/programs/gtk.nix home/programs/atuin.nix home/programs/ghostty.nix
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "remove: delete dead home programs"
```

---

### Task 4: Delete dotfiles directory

**Files:**
- Delete: `dotfiles/`

- [ ] **Step 1: Move wallpaper and emacs configs out before deleting**

```bash
mkdir -p home/emacs home/wallpapers
cp dotfiles/emacs/early-init.el home/emacs/early-init.el
cp dotfiles/emacs/init.el home/emacs/init.el
cp dotfiles/wallpapers/merry-hd.jpg home/wallpapers/merry-hd.jpg
```

- [ ] **Step 2: Delete dotfiles**

```bash
rm -rf dotfiles
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "remove: delete dotfiles, migrate emacs/wallpaper to home/"
```

---

### Task 5: Create emacs HM module

**Files:**
- Create: `home/programs/emacs.nix`

This module symlinks emacs config from the repo (in-store) and ensures emacs is available. The config files live at `home/emacs/` in the repo.

- [ ] **Step 1: Create home/programs/emacs.nix**

```nix
# ============================================================================
# Emacs Configuration
# ============================================================================
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.emacs-config;
in
{
  options.programs.emacs-config = {
    enable = lib.mkEnableOption "Emacs configuration";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/emacs/early-init.el".source = ../emacs/early-init.el;
      ".config/emacs/init.el".source = ../emacs/init.el;
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/emacs.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat: add emacs HM module with in-store config"
```

---

### Task 6: Rewrite sway HM module

**Files:**
- Modify: `home/programs/sway.nix`

Full inline config migrated from dotfiles/sway/config. Uses `wayland.windowManager.sway` native HM. Wallpaper from Nix store.

- [ ] **Step 1: Rewrite home/programs/sway.nix**

```nix
# ============================================================================
# Sway Home Manager Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.sway-config;
  c = import ../../lib { inherit lib; };
in
{
  options.programs.sway-config = {
    enable = lib.mkEnableOption "Sway user configuration";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      package = null; # managed by NixOS module

      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "rofi -show drun -show-icons";

        output.eDP-1 = {
          resolution = "1920x1080";
          position = "0 0";
          bg = "${./../wallpapers/merry-hd.jpg} fill";
        };

        input = {
          "type:keyboard" = {
            xkb_layout = "es";
            xkb_variant = "cat";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
            dwt = "enabled";
          };
        };

        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };

        gaps = {
          inner = 5;
          outer = 10;
          smart = "on";
        };

        window = {
          border = 2;
          commands = [
            {
              criteria.app_id = "pavucontrol";
              command = "floating enable, resize set 800 600";
            }
            {
              criteria.app_id = "nm-connection-editor";
              command = "floating enable";
            }
            {
              criteria.app_id = "blueman-manager";
              command = "floating enable";
            }
            {
              criteria.app_id = "org.gnome.Calculator";
              command = "floating enable";
            }
            {
              criteria.title = "Picture-in-Picture";
              command = "floating enable, sticky enable";
            }
            {
              criteria.app_id = "xdg-desktop-portal-gtk";
              command = "floating enable";
            }
          ];
        };

        colors = {
          focused = {
            border = c.colors.n9;
            background = c.colors.n1;
            text = c.colors.n6;
            indicator = c.colors.n8;
            childBorder = c.colors.n9;
          };
          focusedInactive = {
            border = c.colors.n3;
            background = c.colors.n0;
            text = c.colors.n4;
            indicator = c.colors.n3;
            childBorder = c.colors.n3;
          };
          unfocused = {
            border = c.colors.n3;
            background = c.colors.n0;
            text = c.colors.n4;
            indicator = c.colors.n3;
            childBorder = c.colors.n3;
          };
          urgent = {
            border = c.colors.n11;
            background = c.colors.n11;
            text = c.colors.n6;
            indicator = c.colors.n11;
            childBorder = c.colors.n11;
          };
        };

        keybindings =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
          in
          lib.mkOptionDefault {
            # Apps
            "${mod}+Return" = "exec foot -e tmux";
            "${mod}+Shift+Return" = "exec foot";
            "${mod}+d" = "exec rofi -show drun -show-icons";
            "${mod}+e" = "exec foot -e yazi";
            "${mod}+Shift+e" = "exec thunar";
            "${mod}+b" = "exec brave";
            "${mod}+Shift+b" = "exec nyxt";
            "${mod}+n" = "exec foot -e nvim";
            "${mod}+Shift+n" = "exec emacs";

            # Window management
            "${mod}+q" = "kill";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+f" = "fullscreen disable";
            "${mod}+space" = "floating toggle";
            "${mod}+t" = "layout toggle split tabbed";

            # Screen lock
            "${mod}+Escape" = "exec swaylock -f -c ${c.colors.n0}";

            # Focus
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            # Move window
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            # Workspaces
            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
            "${mod}+8" = "workspace 8";
            "${mod}+9" = "workspace 9";
            "${mod}+0" = "workspace 10";

            # Move to workspace
            "${mod}+Shift+1" = "move container to workspace 1";
            "${mod}+Shift+2" = "move container to workspace 2";
            "${mod}+Shift+3" = "move container to workspace 3";
            "${mod}+Shift+4" = "move container to workspace 4";
            "${mod}+Shift+5" = "move container to workspace 5";
            "${mod}+Shift+6" = "move container to workspace 6";
            "${mod}+Shift+7" = "move container to workspace 7";
            "${mod}+Shift+8" = "move container to workspace 8";
            "${mod}+Shift+9" = "move container to workspace 9";
            "${mod}+Shift+0" = "move container to workspace 10";

            # Workspace navigation
            "${mod}+Tab" = "workspace next";
            "${mod}+Shift+Tab" = "workspace prev";

            # Scratchpad
            "${mod}+s" = "scratchpad show";
            "${mod}+Shift+s" = "move scratchpad";

            # Layout
            "${mod}+backslash" = "split h";
            "${mod}+minus" = "split v";

            # Screenshots
            "${mod}+p" =
              "exec f=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && grim \"$f\" && wl-copy < \"$f\"";
            "${mod}+Shift+p" =
              "exec f=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\"";
            "Print" = "exec grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png";

            # Clipboard
            "${mod}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";

            # Reload
            "${mod}+Shift+c" = "reload";

            # Exit
            "${mod}+Shift+x" = "exec wlogout";

            # Media keys
            "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
            "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
            "XF86AudioMute" = "exec pamixer --toggle";
            "XF86AudioMicMute" = "exec pamixer --default-source --toggle";
            "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
            "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
            "XF86AudioPlay" = "exec playerctl play-pause";
            "XF86AudioNext" = "exec playerctl next";
            "XF86AudioPrev" = "exec playerctl previous";
          };

        modes = {
          resize = {
            "h" = "resize shrink width 20px";
            "l" = "resize grow width 20px";
            "k" = "resize shrink height 20px";
            "j" = "resize grow height 20px";
            "Left" = "resize shrink width 20px";
            "Right" = "resize grow width 20px";
            "Up" = "resize shrink height 20px";
            "Down" = "resize grow height 20px";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        startup = [
          { command = "swaybg -i ${./../wallpapers/merry-hd.jpg} -m fill"; }
          { command = "swaync"; }
          { command = "nm-applet --indicator"; }
          { command = "wl-paste --type text --watch cliphist store"; }
          { command = "wl-paste --type image --watch cliphist store"; }
        ];

        bars = [ { command = "swaybar"; } ];
      };

      extraConfig = ''
        default_border pixel 2
        default_floating_border pixel 2
        hide_edge_borders smart
        seat seat0 xcursor_theme Nordzy-cursors 24
      '';
    };

    home = {
      packages = with pkgs; [
        grim
        slurp
        wl-clipboard
        cliphist
        pamixer
        brightnessctl
        playerctl
        swaylock
        swayidle
        wlogout
        swaybg
        networkmanagerapplet
      ];

      pointerCursor = {
        gtk.enable = true;
        name = c.cursor.name;
        package = pkgs.${c.cursor.package};
        size = 24;
      };
    };

    xdg.userDirs.extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/sway.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: sway config inline, no dotfiles"
```

---

### Task 7: Rewrite rofi HM module

**Files:**
- Modify: `home/programs/rofi.nix`

Nord theme inline as `extraConfig` rasi block. No dotfiles.

- [ ] **Step 1: Rewrite home/programs/rofi.nix**

```nix
# ============================================================================
# Rofi Configuration — Nord Theme
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.rofi-config;
  c = import ../../lib { inherit lib; };
in
{
  options.programs.rofi-config = {
    enable = lib.mkEnableOption "Rofi launcher configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      pass = {
        enable = true;
        stores = [ "password-store" ];
      };
      extraConfig = {
        modi = "drun";
        show-icons = true;
        font = "JetBrainsMono Nerd Font 12";
      };
      theme =
        let
          inherit (c.colors)
            n0 n1 n2 n3 n4 n6 n8 n13
            ;
        in
        with lib;
        mkLiteral;
        {
          "*" = {
            nord0 = n0;
            nord1 = n1;
            nord2 = n2;
            nord3 = n3;
            nord4 = n4;
            nord6 = n6;
            nord8 = n8;
            background-color = mkLiteral "transparent";
            text-color = n4;
            font = "JetBrainsMono Nerd Font 12";
          };
          window = {
            background-color = n0;
            border = mkLiteral "2px solid";
            border-color = n8;
            border-radius = 8;
            width = "40%";
            padding = 0;
          };
          mainbox = {
            background-color = n0;
            children = mkLiteral "[ inputbar, listview, message ]";
            spacing = 0;
            padding = 0;
          };
          inputbar = {
            background-color = n1;
            text-color = n6;
            padding = mkLiteral "12px 16px";
            children = mkLiteral "[ prompt, textbox-prompt-sep, entry ]";
          };
          prompt.text-color = n8;
          textbox-prompt-sep = {
            expand = false;
            str = " ";
            text-color = n3;
          };
          entry = {
            text-color = n6;
            placeholder-color = n3;
            placeholder = "Search...";
          };
          listview = {
            background-color = n0;
            lines = 12;
            columns = 1;
            scrollbar = false;
            padding = mkLiteral "8px 0";
            fixed-height = true;
          };
          element = {
            padding = mkLiteral "8px 16px";
            spacing = 8;
          };
          "element normal.normal" = {
            background-color = n0;
            text-color = n4;
          };
          "element selected.normal" = {
            background-color = n2;
            text-color = n8;
            border = mkLiteral "0 0 0 3px solid";
            border-color = n8;
          };
          "element alternate.normal" = {
            background-color = n0;
            text-color = n4;
          };
          element-icon.size = "24px";
          element-text.text-color = mkLiteral "inherit";
          message = {
            background-color = n1;
            padding = mkLiteral "8px 16px";
          };
          textbox.text-color = n4;
          scrollbar = {
            handle-color = n3;
            handle-width = "4px";
          };
        };
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/rofi.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: rofi Nord theme inline, no dotfiles"
```

---

### Task 8: Rewrite swaync HM module

**Files:**
- Modify: `home/programs/swaync.nix`

Config JSON and CSS inline. No dotfiles.

- [ ] **Step 1: Rewrite home/programs/swaync.nix**

```nix
# ============================================================================
# SwayNC Notification Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.swaync-config;
in
{
  options.services.swaync-config = {
    enable = lib.mkEnableOption "SwayNotificationCenter configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [ swaynotificationcenter ];

      file = {
        ".config/swaync/config.json".text = builtins.toJSON {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "top";
          layer-shell = true;
          cssPriority = "application";
          control-center-margin-top = 8;
          control-center-margin-bottom = 0;
          control-center-margin-right = 10;
          control-center-margin-left = 0;
          notification-2fa-action = true;
          timeout = 5;
          timeout-low = 3;
          timeout-critical = 0;
          fit-to-screen = false;
          control-center-width = 420;
          control-center-height = 600;
          notification-window-width = 380;
          keyboard-shortcuts = true;
          image-visibility = "when-available";
          transition-time = 150;
          hide-on-clear = true;
          hide-on-action = true;
          text-empty = "No notifications";
          scripts = { };
          notification-visibility = { };
          widgets = [
            "title"
            "dnd"
            "notifications"
          ];
        };

        ".config/swaync/style.css".text = ''
          /* ── Global ── */
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 14px;
            font-weight: 500;
          }

          .notification-row {
            outline: none;
            margin: 4px 8px;
          }

          .notification-row:focus,
          .notification-row:hover {
            background: transparent;
          }

          .notification {
            background: #2e3440;
            border: 1px solid #4c566a;
            border-radius: 12px;
            padding: 0;
            margin: 0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
          }

          .notification.low { border-color: alpha(#4c566a, 0.6); }
          .notification.normal { border-color: #4c566a; }
          .notification.critical {
            border-color: #bf616a;
            background: alpha(#bf616a, 0.08);
          }

          .notification-content {
            padding: 12px 16px;
            background: transparent;
          }

          .notification-default-action {
            padding: 12px 16px;
            border-radius: 12px;
            background: #2e3440;
            border: none;
            color: #d8dee9;
            transition: background 0.2s ease;
          }
          .notification-default-action:hover { background: #3b4252; }

          .notification-action {
            padding: 8px 16px;
            border-radius: 0 0 12px 12px;
            background: #3b4252;
            border: none;
            border-top: 1px solid alpha(#4c566a, 0.4);
            color: #d8dee9;
            transition: background 0.2s ease;
          }
          .notification-action:hover { background: #434c5e; }
          .notification-action:first-child { border-bottom-left-radius: 12px; }
          .notification-action:last-child { border-bottom-right-radius: 12px; }

          .summary { color: #eceff4; font-weight: 700; font-size: 14px; }
          .body { color: #d8dee9; font-weight: 400; font-size: 13px; }
          .time { color: #4c566a; font-size: 12px; }
          .image { margin: 8px; border-radius: 8px; }

          .inline-reply {
            background: #3b4252;
            border: 1px solid #4c566a;
            border-radius: 8px;
            padding: 8px 12px;
            margin: 4px;
            color: #d8dee9;
          }
          .inline-reply:disabled { color: #4c566a; }

          .close-button {
            background: alpha(#bf616a, 0.2);
            color: #bf616a;
            border-radius: 50%;
            padding: 4px;
            margin: 8px;
            min-width: 20px;
            min-height: 20px;
            transition: all 0.2s ease;
          }
          .close-button:hover { background: #bf616a; color: #eceff4; }

          .control-center {
            background: alpha(#2e3440, 0.95);
            border: 1px solid #4c566a;
            border-radius: 12px;
            padding: 8px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
          }

          .control-center-list { background: transparent; padding: 0; }
          .control-center-list-placeholder { color: #4c566a; font-style: italic; opacity: 0.8; }

          .control-center-clear-all {
            background: alpha(#bf616a, 0.15);
            color: #bf616a;
            border: 1px solid alpha(#bf616a, 0.3);
            border-radius: 8px;
            padding: 8px 16px;
            margin: 4px 8px;
            font-weight: 600;
            transition: all 0.2s ease;
          }
          .control-center-clear-all:hover { background: alpha(#bf616a, 0.25); border-color: #bf616a; }

          .control-center-dnd {
            background: #3b4252;
            border: 1px solid #4c566a;
            border-radius: 8px;
            padding: 6px 12px;
            margin: 4px 8px;
            transition: all 0.2s ease;
          }
          .control-center-dnd:checked { background: alpha(#d08770, 0.2); border-color: #d08770; color: #d08770; }

          .control-center-header { color: #eceff4; font-weight: 700; font-size: 16px; padding: 8px 12px; margin-bottom: 4px; }

          .widget-title { padding: 8px 12px; color: #eceff4; font-size: 16px; font-weight: 700; }
          .widget-title > button { background: transparent; color: #4c566a; border-radius: 8px; padding: 4px 8px; transition: all 0.2s ease; }
          .widget-title > button:hover { background: alpha(#d8dee9, 0.08); color: #d8dee9; }

          .widget-dnd { padding: 4px 12px; color: #d8dee9; font-size: 13px; }
          .widget-dnd > switch { background: #3b4252; border: 1px solid #4c566a; border-radius: 20px; min-height: 20px; min-width: 40px; transition: all 0.2s ease; }
          .widget-dnd > switch:checked { background: alpha(#d08770, 0.3); border-color: #d08770; }
          .widget-dnd > switch slider { background: #d8dee9; border-radius: 50%; min-height: 16px; min-width: 16px; margin: 2px; }

          .widget-notifications { margin: 4px; }
          .widget-notifications .notification-row { margin: 2px 0; }

          .control-center-list > scrollbar { background: transparent; }
          .control-center-list > scrollbar > range > trough > slider { background: #4c566a; border-radius: 4px; min-width: 4px; }

          @keyframes urgencyCritical {
            0% { border-color: #bf616a; box-shadow: 0 0 0 0 alpha(#bf616a, 0.4); }
            50% { border-color: alpha(#bf616a, 0.6); box-shadow: 0 0 12px 2px alpha(#bf616a, 0.2); }
            100% { border-color: #bf616a; box-shadow: 0 0 0 0 alpha(#bf616a, 0.4); }
          }
          .notification.critical { animation: urgencyCritical 2s ease-in-out infinite; }

          .notification-group { margin: 2px 8px; }
          .notification-group-header { color: #88c0d0; font-weight: 600; font-size: 13px; }
          .notification-group-buttons { margin: 4px; }
          .notification-group-buttons > button { background: #3b4252; border: 1px solid #4c566a; border-radius: 8px; color: #d8dee9; padding: 4px 12px; margin: 2px; transition: all 0.2s ease; }
          .notification-group-buttons > button:hover { background: #434c5e; }
        '';
      };
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/swaync.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: swaync config inline, no dotfiles"
```

---

### Task 9: Simplify shells to bash only

**Files:**
- Modify: `home/programs/shells.nix`

Remove fish and zsh. Keep bash only. Remove zoxide fish/zsh integrations.

- [ ] **Step 1: Rewrite home/programs/shells.nix**

```nix
# ============================================================================
# Bash Shell Configuration
# ============================================================================
{ lib, pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "clip" ''
      file="$1"
      if [ -z "$file" ]; then
        file=$(${pkgs.television}/bin/tv)
        [ -z "$file" ] && exit 0
      fi
      cat "$file" | ${pkgs.wl-clipboard}/bin/wl-copy
      echo "Copied $file to clipboard"
    '')
    (pkgs.writeShellScriptBin "E" ''
      selected=$(${pkgs.television}/bin/tv)
      if [ -n "$selected" ]; then
        nvim "$selected"
      fi
    '')
    (pkgs.writeShellScriptBin "b" ''
      branch=$(${pkgs.television}/bin/tv git-branch)
      if [ -n "$branch" ]; then
        git checkout "$branch"
      fi
    '')
    (pkgs.writeShellScriptBin "S" ''
      host=$(${pkgs.television}/bin/tv ssh-hosts)
      if [ -n "$host" ]; then
        ssh "$host"
      fi
    '')
  ];

  programs = {
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    bash = {
      enable = true;

      initExtra = ''
        # PATH managed by home.sessionPath

        # Desvincular C-l de clear-screen dentro de tmux
        if [ -n "$TMUX" ]; then
          bind -r '\C-l'
        fi

        # SOPS Secrets Environment Variables
        if [ -f /run/secrets/zai_api_key ]; then
          export ZAI_API_KEY="$(cat /run/secrets/zai_api_key)"
        fi
        if [ -f /run/secrets/brave_api_key ]; then
          export BRAVE_API_KEY="$(cat /run/secrets/brave_api_key)"
        fi

        if [ -f ~/.stripe/stripe-completion.bash ]; then
          source ~/.stripe/stripe-completion.bash
        fi

        if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
      '';
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/shells.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: shells to bash only"
```

---

### Task 10: Update foot to use lib colors

**Files:**
- Modify: `home/programs/foot.nix`

- [ ] **Step 1: Rewrite home/programs/foot.nix**

```nix
# ============================================================================
# Foot Terminal Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.foot-config;
  c = import ../../lib { inherit lib; };
in
{
  options.programs.foot-config = {
    enable = lib.mkEnableOption "Foot terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=14";
          dpi-aware = "yes";
          login-shell = "yes";
          pad = "10x10";
        };

        colors-dark = {
          background = c.colors.n0;
          foreground = c.colors.n4;
          regular0 = c.colors.n1;
          regular1 = c.colors.n11;
          regular2 = c.colors.n14;
          regular3 = c.colors.n13;
          regular4 = c.colors.n9;
          regular5 = c.colors.n15;
          regular6 = c.colors.n8;
          regular7 = c.colors.n5;
          bright0 = c.colors.n3;
          bright1 = c.colors.n11;
          bright2 = c.colors.n14;
          bright3 = c.colors.n13;
          bright4 = c.colors.n9;
          bright5 = c.colors.n15;
          bright6 = c.colors.n7;
          bright7 = c.colors.n6;
        };
      };
    };
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/foot.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: foot colors from lib"
```

---

### Task 11: Update lazygit to use lib theme

**Files:**
- Modify: `home/programs/lazygit.nix`

Read current file first — it may just be `enable = true`. The theme was in `home/themes/nord.nix`. Need to move theme into the lazygit module.

- [ ] **Step 1: Rewrite home/programs/lazygit.nix**

```nix
# ============================================================================
# LazyGit Configuration
# ============================================================================
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.lazygit;
  c = import ../../lib { inherit lib; };
in
{
  config = lib.mkIf cfg.enable {
    programs.lazygit.settings.gui.theme = c.mkLazyGitTheme c.colors;
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/lazygit.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: lazygit theme from lib"
```

---

### Task 12: Update zellij to use lib

**Files:**
- Modify: `home/programs/zellij.nix`

Read current file to see what needs changing. Theme was set in `home/themes/nord.nix` as `programs.zellij.settings.theme = "nord"`. This can stay as-is since zellij has a built-in "nord" theme — just ensure it's set in the zellij module directly.

- [ ] **Step 1: Add theme to home/programs/zellij.nix**

Ensure `programs.zellij.settings.theme = "nord"` is present in the zellij nix file. If it's already there, skip. If the theme was only in themes/nord.nix, add it to the zellij module's config block.

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/zellij.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: zellij theme in module"
```

---

### Task 13: Update tmux to ensure nord plugin

**Files:**
- Modify: `home/programs/tmux.nix`

The nord tmux plugin was set in `home/themes/nord.nix`. Ensure it's in the tmux module's plugins list.

- [ ] **Step 1: Ensure nord plugin in tmux plugins**

Check `home/programs/tmux.nix` and ensure `programs.tmux.plugins` includes the nord plugin. If it was only in themes/nord.nix, add:

```nix
programs.tmux.plugins = with pkgs.tmuxPlugins; [ nord ];
```

to the tmux module's config block.

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse home/programs/tmux.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: tmux nord plugin in module"
```

---

### Task 14: Delete home/themes/nord.nix and update imports

**Files:**
- Delete: `home/themes/nord.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Delete themes directory**

```bash
rm -rf home/themes
```

- [ ] **Step 2: Rewrite home/default.nix**

```nix
# ============================================================================
# Home Manager Configuration
# ============================================================================
{
  config,
  pkgs,
  lib,
  ...
}:

let
  c = import ../lib { inherit lib; };
in
{
  imports = [
    ./programs
    ./packages
    ./services
    ./aliases.nix
  ];

  # GTK Theme
  gtk = {
    enable = true;
    theme = {
      name = c.gtk;
      package = pkgs.${c.gtkPackage};
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Cursor
  home.pointerCursor = {
    gtk.enable = true;
    name = c.cursor.name;
    package = pkgs.${c.cursor.package};
    size = 24;
  };

  # Dark mode
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
    ignore-scripts=true
  '';

  # PATH additions
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "code -w";
    TERMINAL = "foot";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "foot.desktop" ];
    };
  };

  # Program enables
  programs.sway-config.enable = true;
  programs.foot-config.enable = true;
  programs.rofi-config.enable = true;
  programs.emacs-config.enable = true;

  # Git settings
  programs.git.settings = {
    user.name = lib.mkDefault "Kevin Curtet";
    user.email = lib.mkDefault "kcurtet@gmail.com";
    user.signingKey = lib.mkDefault "kcurtet@gmail.com";
  };

  home.stateVersion = "26.05";
}
```

- [ ] **Step 3: Verify syntax**

```bash
nix-instantiate --parse home/default.nix > /dev/null
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "refactor: home/default.nix GTK/cursor from lib, delete themes/"
```

---

### Task 15: Update home/programs/default.nix

**Files:**
- Modify: `home/programs/default.nix`

- [ ] **Step 1: Rewrite home/programs/default.nix**

```nix
# ============================================================================
# Program Configurations - Index
# ============================================================================
{
  imports = [
    ./bat.nix
    ./direnv.nix
    ./emacs.nix
    ./foot.nix
    ./git.nix
    ./lazygit.nix
    ./rofi.nix
    ./shells.nix
    ./ssh.nix
    ./starship.nix
    ./sway.nix
    ./swaync.nix
    ./television.nix
    ./tmux.nix
    ./yazi.nix
    ./zellij.nix
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "refactor: programs index, only live modules"
```

---

### Task 16: Update home/packages/gui.nix

**Files:**
- Modify: `home/packages/gui.nix`

Remove ghostty, gnome-tweaks.

- [ ] **Step 1: Rewrite home/packages/gui.nix**

```nix
# ============================================================================
# GUI Applications
# ============================================================================
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Browsers
    brave
    librewolf
    chromium
    google-chrome

    # Communication
    telegram-desktop
    discord

    # Media
    spotifywm

    # Gaming
    hmcl
    mgba

    # Privacy
    tor-browser

    # Note taking
    obsidian

    # Office
    libreoffice-fresh
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "refactor: gui.nix remove ghostty, gnome-tweaks"
```

---

### Task 17: Update modules/desktop/sway/default.nix

**Files:**
- Modify: `modules/desktop/sway/default.nix`

Remove wofi, update cursor to Nordzy, add pamixer/brightnessctl/playerctl to system packages.

- [ ] **Step 1: Rewrite modules/desktop/sway/default.nix**

```nix
# ============================================================================
# Sway Wayland Compositor Configuration Module
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.sway;
in
{
  options.desktop.sway = {
    enable = lib.mkEnableOption "Sway Wayland compositor";

    xkb = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "es";
        description = "Keyboard layout";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "cat";
        description = "Keyboard variant";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export GDK_BACKEND=wayland,x11,*
        export QT_QPA_PLATFORM="wayland;xcb"
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER=wayland
        export CLUTTER_BACKEND=wayland
        export GTK_IM_MODULE=simple
        export XCURSOR_SIZE=24
        export XCURSOR_THEME=Nordzy-cursors
      '';
    };

    services.xserver = {
      xkb.layout = cfg.xkb.layout;
      xkb.variant = cfg.xkb.variant;
    };

    services.dbus.enable = true;
    hardware.graphics.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config.sway = {
        default = lib.mkForce [ "wlr" "gtk" ];
      };
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      swaylock
      swayidle
      swaybg
      libnotify
      pavucontrol
      thunar
      thunar-volman
      thunar-archive-plugin
      p7zip
      unzip
      zip
      unrar
      file-roller
      xdg-utils
      xdg-user-dirs
      v4l-utils
      foot
      pamixer
      brightnessctl
      playerctl
    ];
  };
}
```

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse modules/desktop/sway/default.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: sway module remove wofi, add audio/brightness"
```

---

### Task 18: Update hosts/panther/default.nix

**Files:**
- Modify: `hosts/panther/default.nix`

Remove `../../modules/laptop` import and `laptop.powerManagement.enable`. Remove `programs.fish.enable = true`.

- [ ] **Step 1: Edit hosts/panther/default.nix**

Remove these lines:
- `../../modules/laptop` from imports
- `laptop.powerManagement.enable = false;` section
- `programs.fish.enable = true;`

- [ ] **Step 2: Verify syntax**

```bash
nix-instantiate --parse hosts/panther/default.nix > /dev/null
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "refactor: panther host remove laptop, fish"
```

---

### Task 19: Update home/programs/bat.nix

**Files:**
- Modify: `home/programs/bat.nix`

Theme was set in `home/themes/nord.nix`. Ensure `programs.bat.config.theme = "Nord"` is in bat.nix directly.

- [ ] **Step 1: Check and update bat.nix**

Ensure `programs.bat.config.theme = "Nord"` is set. If already there, skip.

- [ ] **Step 2: Commit if changed**

```bash
git add -A && git commit -m "refactor: bat theme in module"
```

---

### Task 20: Lint, format, and verify build

**Files:**
- All modified files

- [ ] **Step 1: Run linters**

```bash
statix check .
deadnix .
```

Fix any issues found.

- [ ] **Step 2: Format all Nix files**

```bash
nixfmt-tree .
```

- [ ] **Step 3: Dry build**

```bash
sudo nixos-rebuild dry-build --flake .#panther
```

Expected: build succeeds without errors.

- [ ] **Step 4: Commit formatting fixes**

```bash
git add -A && git commit -m "style: format and lint fixes"
```

---

### Task 21: Apply and test

- [ ] **Step 1: Apply config**

```bash
sudo nixos-rebuild switch --flake .#panther
```

- [ ] **Step 2: Log into Sway and verify**

- Sway launches with correct wallpaper
- swaybar shows
- rofi works with Nord theme (Mod+d)
- foot terminal opens (Mod+Return)
- swaync notifications work
- Screenshots work (Mod+p)
- Clipboard works (Mod+v)

- [ ] **Step 3: Final commit if any fixes needed**

```bash
git add -A && git commit -m "fix: post-apply corrections"
```
