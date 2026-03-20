# Hyprland Desktop Module

Hyprland is a dynamic tiling Wayland compositor based on wlroots that doesn't sacrifice on its looks.

## Usage

Add the module to your host configuration:

```nix
imports = [
  # ... other imports
  ../../modules/desktop/hyprland
];
```

Then enable it:

```nix
desktop.hyprland = {
  enable = true;

  # Optional: Customize keyboard layout
  xkb = {
    layout = "us";
    variant = "";
  };

  # Optional: Add or remove packages
  extraPackages = with pkgs; [
    # Default packages included:
    # - wl-clipboard (Wayland clipboard utilities)
    # - waybar (status bar)
    # - rofi-wayland (application launcher)
    # - swaybg (wallpaper utility)
    # - swaylock-effects (screen lock)
    # - wlogout (logout menu)
    # - kanshi (autorandr for wlroots)
    # - hyprpicker (color picker)
    # - grim (screenshot)
    # - slurp (selection tool)

    kitty      # Terminal
    firefox    # Browser
  ];
};
```

## Configuration

### Hyprland Config

Copy the example configuration to your home directory:

```bash
mkdir -p ~/.config/hypr
cp /etc/nixos/modules/desktop/hyprland/hyprland.conf.example ~/.config/hypr/hyprland.conf
```

### Waybar Config

Example Waybar config is referenced in `hyprland.conf`. Create `~/.config/waybar/config` and `~/.config/waybar/style.css`.

### Themes

This module uses the Nord color scheme by default. To customize colors, edit your `hyprland.conf`:

```conf
col.active_border = rgba(88c0d0ee)   # Nord frost
col.inactive_border = rgba(4c566aee) # Nord polar night
```

## Common Tasks

### Set wallpaper

Edit `~/.config/hypr/hyprland.conf`:

```conf
exec-once = swaybg -i /path/to/wallpaper.png
```

### Enable autorandr-like behavior

Create `~/.config/kanshi/config`:

```kanshi
profile highres {
    output eDP-1 enable scale 2
}
profile laptop {
    output eDP-1 enable scale 1
}
```

### Screen locking

`swoylock-effects` is included. Add a keybinding in `hyprland.conf`:

```conf
bind = $mod, L, exec, swaylock-effects
```

## Notes

- Hyprland uses the Wayland protocol exclusively (Xwayland is enabled for legacy apps)
- Keyboard settings are managed via NixOS options (`services.xserver.xkb`)
- XDG portals are configured for file access, screen sharing, etc.

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hyprland Configuration](https://wiki.hyprland.org/Configuring/Configuring-Hyprland/)
- [Waybar Documentation](https://github.com/Alexays/Waybar/wiki)
