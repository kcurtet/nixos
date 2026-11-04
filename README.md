# nixos

Mi configuración de NixOS: todo el sistema de mi portátil descrito en código, con flakes, home-manager y secretos cifrados. Reinstalar el equipo desde cero es clonar este repo y aplicar un comando.

> *My NixOS configuration as a flake: reusable modules with `enable` options, home-manager for the user environment, sops-nix for encrypted secrets, and CI that checks, formats and lints every push.*

## Qué tiene de interesante

- **Flake reproducible:** versiones fijadas en `flake.lock`; el mismo commit da el mismo sistema.
- **Módulos propios con opciones:** cada pieza (NVIDIA, juegos, virtualización, servicios…) se activa con `enable = true` desde el host, sin tocar el módulo.
- **Secretos cifrados con [sops-nix](https://github.com/Mic92/sops-nix):** las API keys viven cifradas (AES-256 + age) en el repo y solo se descifran en el equipo, en `/run/secrets`.
- **Calidad automática:** `nixfmt`, `statix` y `deadnix` en un hook de pre-commit y en [CI](.github/workflows/ci.yml).
- **Gráficos híbridos Intel + NVIDIA** con *specialisations*: el menú de arranque ofrece varios modos de GPU.

## Estructura

```
.
├── flake.nix              entradas (nixpkgs, home-manager, sops-nix, nixvim) y hosts
├── hosts/
│   └── panther/           portátil principal: hardware, red y qué módulos activa
├── modules/               módulos de sistema reutilizables
│   ├── desktop/           Sway y KDE
│   ├── gaming/            Steam, GameMode, Gamescope, Wine
│   ├── laptop/            TLP con umbrales de carga de batería
│   ├── nvidia/            PRIME offload/sync + specialisations
│   ├── services/          Tailscale, Syncthing, DNS local con dnsmasq, Ollama, Tor
│   └── virtualization/    Docker y KVM/QEMU con libvirt
├── home/                  home-manager: programas, paquetes, alias y tema Nord
├── dotfiles/              configs que no se gestionan como módulo (Sway, Waybar, Emacs…)
├── lib/                   funciones y valores compartidos (usuario, tema)
├── overlays/              Neovim desde mi repo kcurtet/nixvim
├── scripts/               nix-apply y nboot: aplicar cambios con revisión del diff
└── secrets/               secretos cifrados con sops
```

## Módulos y cómo se activan

Todo se decide en [`hosts/panther/default.nix`](hosts/panther/default.nix):

```nix
virtualization.docker.enable = true;
virtualization.libvirtd.enable = true;
gaming.enable = true;

my.services = {
  tailscale.enable = true;
  syncthing.enable = true;
  dnsmasq = {
    enable = true;                       # DNS local con caché
    upstreamServers = [ "1.1.1.1" "8.8.8.8" ];
    cacheSize = 1000;
  };
};
```

| Módulo | Qué hace |
| --- | --- |
| `my.services.dnsmasq` | DNS local con caché en `127.0.0.1` y dominios `*.localhost` para desarrollo |
| `my.services.tailscale` | VPN para llegar a mis equipos desde fuera sin abrir puertos |
| `virtualization` | Docker (con lazydocker y dive) y máquinas virtuales KVM/QEMU |
| `hardware.nvidiaConfig` | NVIDIA PRIME con modo offload por defecto y *specialisations* `on-the-go` y `disable-intel` |
| `laptop.powerManagement` | TLP con perfil de energía y umbrales de carga (40–80 %) |
| `gaming` | Steam, GameMode, Gamescope y Wine, cada uno activable por separado |

## Secretos

[`.sops.yaml`](.sops.yaml) define la clave pública *age* con la que se cifra [`secrets/secrets.yaml`](secrets/secrets.yaml). En el equipo, sops-nix descifra cada secreto en `/run/secrets/<nombre>` con permisos `0600` y propietario el usuario:

```bash
sops secrets/secrets.yaml      # editar los secretos (se cifran al guardar)
```

## Uso

```bash
# Aplicar la configuración
sudo nixos-rebuild switch --flake .#panther

# O con mi script: enseña el diff, hace commit y aplica
nix-apply

# Entorno de desarrollo con nixd, nixfmt, statix, deadnix y sops
nix develop

# Comprobaciones (lo mismo que la CI)
nix flake check
nix fmt
```

## Añadir otro equipo

1. Crear `hosts/<nombre>/` con su `default.nix`, `hardware.nix` y `networking.nix`.
2. Añadirlo en `flake.nix`: `<nombre> = mkHost "<nombre>";`
3. Activar los módulos que necesite en su `default.nix`.
