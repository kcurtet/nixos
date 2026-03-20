# Hyprland Nix Reference

Extracted from Hyprland Wiki - LLM instructions for configuring Hyprland on NixOS.

---

## NixOS Module

Basic installation in `configuration.nix`:

```nix
{
  programs.hyprland.enable = true;
  # Optional: hint Electron apps to use Wayland
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = [
    pkgs.kitty  # required for default Hyprland config
  ];
}
```

### Using Flake for Development Version

**flake.nix:**
```nix
{
  inputs.hyprland.url = "github:hyprwm/Hyprland";

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

**configuration.nix:**
```nix
{inputs, pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
}
```

### Mesa Version Mismatch Fix

If experiencing lag/FPS drops with Hyprland flake on stable NixOS:

```nix
{pkgs, inputs, ...}: let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  hardware.graphics = {
    package = pkgs-unstable.mesa;
    enable32Bit = true;  # for Steam
    package32 = pkgs-unstable.pkgsi686Linux.mesa;
  };
}
```

---

## Home Manager Module

Basic installation in `home.nix`:

```nix
{
  programs.kitty.enable = true;  # required for default config
  wayland.windowManager.hyprland.enable = true;
}
```

### With Flake Input

**flake.nix:**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = {nixpkgs, home-manager, hyprland, ...}: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {
          wayland.windowManager.hyprland = {
            enable = true;
            package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          };
        }
      ];
    };
  };
}
```

### Declarative Configuration Example

```nix
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      [
        "$mod, F, exec, firefox"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );
  };
}
```

### Using NixOS Module Packages in Home Manager

If NixOS already configures Hyprland, use `null` to inherit:

```nix
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;        # use from NixOS module
    portalPackage = null;  # use from NixOS module
  };
}
```

---

## Theme Configuration

### GTK/GNOME Themes (without Home Manager)

```nix
{
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita";
        icon-theme = "Flat-Remix-Red-Dark";
        font-name = "Noto Sans Medium 11";
        document-font-name = "Noto Sans Medium 11";
        monospace-font-name = "Noto Sans Mono Medium 11";
      };
    }
  ];
}
```

### Home Manager Theme Setup

```nix
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };
}
```

---

## Systemd Environment Fix

For programs not working in systemd services:

```nix
{
  wayland.windowManager.hyprland.systemd.variables = ["--all"];
}
```

---

## Package Options & Overrides

### Package Override

```nix
(pkgs.hyprland.override {
  enableXWayland = true;
  withSystemd = true;
})
```

### Module Options

```nix
{
  programs.hyprland = {  # or wayland.windowManager.hyprland
    enable = true;
    xwayland.enable = true;
  };
}
```

### Nix REPL Override

```bash
nix repl
nix-repl> :lf github:hyprwm/Hyprland
nix-repl> :bl outputs.packages.x86_64-linux.hyprland.override { enableXWayland = false; }
```

---

## Upstream Module (Declarative Settings)

```nix
{inputs, ...}: {
  imports = [inputs.hyprland.nixosModules.default];

  programs.hyprland = {
    plugins = [ /* ... */ ];
    settings = {
      # declarative Hyprland config
    };
  };
}
```

---

## Common Issues

### Cursor Shows Hyprland Icon

No hyprcursor theme installed. Install a cursor theme and add:

```nix
exec-once = hyprctl setcursor [THEME] [SIZE]
```

### Apps Take Long to Start / Screenshare Fails

Multiple portal implementations. Ensure only `xdg-desktop-portal-hyprland` is running.

### Systemd Services Don't See PATH

Add to config:
```nix
wayland.windowManager.hyprland.systemd.variables = ["--all"];
```

---

## Key Links

- **NixOS module options**: https://search.nixos.org/options?query=hyprland
- **Home Manager options**: https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.hyprland.enable
- **Community module (hyprnix)**: https://github.com/hyprland-community/hyprnix
