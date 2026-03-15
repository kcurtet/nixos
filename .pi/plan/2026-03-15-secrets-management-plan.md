# Plan de Implementación: Gestión de Secretos con sops-nix

## 🎯 Objetivo
Implementar un sistema de gestión de secretos cifrados usando **sops-nix** para gestionar API Keys, contraseñas y otros secretos sensibles en NixOS y Home Manager.

---

## 📋 Tareas

### 1. Añadir sops-nix como input en flake.nix
**Archivo:** `flake.nix`

**Cambios:**
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nixvim.url = "github:kcurtet/nixvim";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # NUEVO: sops-nix para gestión de secretos
  sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

**Criterio de aceptación:** El input se añade correctamente y se puede acceder como `inputs.sops-nix`

---

### 2. Crear estructura de directorios para secretos
**Comando:**
```bash
mkdir -p secrets/
```

**Archivos que se crearán:**
- `secrets/` - Directorio para archivos de secretos cifrados
- `secrets/.sops.yaml` - Configuración de sops (llaves SSH/GPG)
- `secrets/secrets.yaml` - Archivo con los secretos (cifrado)

**Criterio de aceptación:** Directorio `secrets/` creado y preparado

---

### 3. Generar/Configurar llaves para SOPS
**Opción A - Usar llave SSH existente:**
```bash
# Listar llaves SSH disponibles
ls -la ~/.ssh/

# Usar llave por defecto para SOPS
echo "creation_rules:" > secrets/.sops.yaml
echo "  - pgp: 'FINGERPRINT_DE_TU_LLAVE_GPG'" >> secrets/.sops.yaml
```

**Opción B - Usar llave GPG (recomendado):**
```bash
# Ver llaves GPG existentes
gpg --list-secret-keys

# Si no tienes, generar una
gpg --full-generate-key
# Tipo: RSA y RSA
# Tamaño: 4096
# Validez: 0 (no expira)
# Nombre, Email, Comentario

# Obtener fingerprint
gpg --list-secret-keys --keyid-format LONG
```

**Archivo `secrets/.sops.yaml`:**
```yaml
creation_rules:
  - age: 'age1...'  # Si usas age (alternativa simple)
  # O
  - pgp: '...'     # Si usas GPG
```

**Criterio de aceptación:** Archivo `.sops.yaml` configurado con tu llave pública

---

### 4. Crear archivo de secretos iniciales
**Archivo:** `secrets/secrets.yaml`

**Contenido inicial (sin cifrar):**
```yaml
# Usuario kx
kx_password: "tu_nueva_contraseña_segura"
kx_email: "kcurtet@gmail.com"

# Servicios (ejemplos)
# syncthing_api_key: "..."
# tailscale_auth_key: "..."
# openai_api_key: "..."
# github_token: "..."
```

**Cifrar archivo:**
```bash
sops --encrypt --encrypted-regex '^(kx_|.*)_password$' \
  --kage 'age1...' secrets/secrets.yaml > secrets/secrets.encrypted.yaml
```

**O más simple:**
```bash
sops secrets/secrets.yaml
# Editar, guardar y cerrar
```

**Criterio de aceptación:** Archivo de secretos cifrado creado

---

### 5. Configurar sops-nix en hosts/panther/default.nix
**Archivo:** `hosts/panther/default.nix`

**Cambios:**

```nix
{ config, lib, pkgs, inputs, ... }:

{
  # ... imports existentes ...

  imports = [
    ./hardware.nix
    ./networking.nix
    ../../modules/nvidia
    ../../modules/gaming
    ../../modules/services
    # NUEVO: Importar sops-nix
    inputs.sops-nix.nixosModules.sops
  ];

  # ... resto de configuración ...

  # Configurar sops-nix
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.home = "/root/.gnupg";
    secrets = {
      kx_password = {
        neededForUsers = true;
      };
    };
  };

  # Modificar configuración de usuario para usar secreto
  users.users.kx = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    # ELIMINAR: initialPassword = "secret";
    hashedPasswordFile = config.sops.secrets.kx_password.path;
  };
}
```

**Criterio de aceptación:** sops-nix configurado y el usuario usa secreto cifrado

---

### 6. Migrar email de git a secreto (Home Manager)
**Archivo:** `home/default.nix`

**Cambios:**

```nix
# Primero, configurar sops-nix en Home Manager
{ config, lib, pkgs, inputs, ... }:

{
  # Importar módulos de sops-nix para Home Manager
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Configurar sops en Home Manager
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      git_signing_key = {
        mode = "0400";
      };
      # Agregar aquí más secretos de usuario
    };
  };

  # Usar secreto en configuración de git
  programs.git.settings = {
    user.signingKey = lib.mkDefault config.sops.secrets.git_signing_key.path;
  };
}
```

**Actualizar `secrets/secrets.yaml`:**
```yaml
git_signing_key: "TU_LLAVE_GPG_FINGERPRINT"
```

**Criterio de aceptación:** Git usa el secreto del archivo cifrado

---

### 7. Añadir .gitignore para secretos
**Archivo:** `.gitignore`

**Añadir:**
```gitignore
# Secretos (jamás committing)
secrets/*.yaml
secrets/*.json
secrets/*.env
!secrets/.sops.yaml  # Solo config de sops
```

**Criterio de aceptación:** Secretos no se commitean

---

### 8. Crear módulo de secretos (opcional pero recomendado)
**Archivo:** `modules/secrets/default.nix`

```nix
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.my.secrets;
  myLib = import ../../lib { inherit lib; };
in
{
  options.my.secrets = {
    enable = lib.mkEnableOption "Secrets management with sops-nix";
    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/secrets.yaml;
      description = "Path to sops secrets file";
    };
  };

  config = lib.mkIf cfg.enable {
    # Importar sops-nix
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # Configuración de sops
    sops = {
      defaultSopsFile = cfg.sopsFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
```

**Uso en `hosts/panther/default.nix`:**
```nix
imports = [
  # ...
  ../../modules/secrets
];

my.secrets.enable = true;
```

**Criterio de aceptación:** Módulo de secretos creado y reusable

---

## 📁 Archivos a Modificar

| Archivo | Acción | Línea aprox |
|---------|--------|-------------|
| `flake.nix` | Modificar | Añadir input `sops-nix` |
| `hosts/panther/default.nix` | Modificar | Importar sops-nix, configurar sops, cambiar password |
| `home/default.nix` | Modificar | Importar sops-nix home module, usar secretos |
| `.gitignore` | Modificar | Añadir reglas de ignorar secretos |

## 📁 Archivos Nuevos

| Archivo | Propósito |
|---------|-----------|
| `secrets/.sops.yaml` | Configuración de llaves SOPS |
| `secrets/secrets.yaml` | Archivo de secretos (cifrado) |
| `modules/secrets/default.nix` | Módulo reusable de secretos |

---

## 🔑 Guía para Añadir Nuevas API Keys

### Pasos para añadir un nuevo secreto:

1. **Editar archivo de secretos:**
   ```bash
   sops secrets/secrets.yaml
   ```

2. **Añadir nueva API Key:**
   ```yaml
   openai_api_key: "sk-..."
   anthropic_api_key: "sk-ant-..."
   github_token: "ghp_..."
   ```

3. **Guardar y cerrar** (sops cifra automáticamente)

4. **Declarar en configuración NixOS:**

   **Para NixOS (servicios del sistema):**
   ```nix
   # hosts/panther/default.nix o módulo de servicio
   sops.secrets.openai_api_key = { };
   ```

   **Para Home Manager (servicios de usuario):**
   ```nix
   # home/default.nix o módulo de programa
   sops.secrets.openai_api_key = {
     mode = "0400";
   };
   ```

5. **Usar el secreto en configuración:**

   **Ejemplo - Variables de entorno:**
   ```nix
   systemd.user.services.openai-client = {
     Service.Environment = [
       "OPENAI_API_KEY=${config.sops.secrets.openai_api_key.path}"
     ];
   };
   ```

   **Ejemplo - Archivo de configuración:**
   ```nix
   xdg.configFile."openai/config.toml".text = ''
     api_key_file = ${config.sops.secrets.openai_api_key.path}
   '';
   ```

   **Ejemplo - Script wrapper:**
   ```nix
   home.packages = [
     (pkgs.writeShellScriptBin "openai-chat" ''
       export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
       exec openai-cli "$@"
     '')
   ];
   ```

### Ejemplos de API Keys Comunes:

```yaml
# Desarrollo
openai_api_key: "sk-..."
anthropic_api_key: "sk-ant-..."
google_ai_api_key: "AIza..."

# Servicios
github_token: "ghp_..."
gitlab_token: "glpat-..."
docker_hub_token: "dckr_..."

# Nube
aws_access_key_id: "AKIA..."
aws_secret_access_key: "..."
cloudflare_api_token: "..."

# Integraciones
slack_bot_token: "xoxb-..."
slack_signing_secret: "..."
discord_token: "MTE..."
```

---

## 🔄 Flujo de Trabajo de Secretos

### Crear nuevo secreto:
```bash
sops secrets/secrets.yaml
# Editar, guardar, salir (cifra automáticamente)
```

### Editar secreto existente:
```bash
sops secrets/secrets.yaml
# Editar, guardar, salir (cifra automáticamente)
```

### Ver secreto (solo lectura):
```bash
sops --decrypt secrets/secrets.yaml | grep openai_api_key
```

### Regenerar archivo de secretos (re-cifrar):
```bash
sops --rotate secrets/secrets.yaml
```

### Añadir nueva llave de acceso (colaborador):
```bash
sops updatekeys secrets/secrets.yaml --pgp NUEVO_FINGERPRINT
```

---

## ⚠️ Riesgos y Consideraciones

### Riesgos:
1. **Pérdida de llaves GPG/SSH** → No se podrán descifrar los secretos
   - **Mitigación:** Backup de llaves GPG/SSH en lugar seguro
2. **Commit de secretos sin cifrar** → Exposición de credenciales
   - **Mitigación:** .gitignore estricto, pre-commit hooks
3. **Archivo de secretos corrompido** → Sistema no arranca
   - **Mitigación:** Backup del archivo de secretos, rollback de git

### Consideraciones:
1. **Necesario ejecutar:** `sudo nixos-rebuild switch` tras cambios en secretos
2. **Secretos de usuario vs. sistema:**
   - Sistema (`/run/secrets/`): Root, servicios del sistema
   - Usuario (`~/.config/sops-nix/secrets/`): Usuario, servicios de usuario
3. **Permisos:** Los secretos del sistema son 000 por defecto (solo root)
4. **Requiere:** `sops` instalado para editar secretos

---

## 📚 Recursos Adicionales

### Documentación:
- [sops-nix GitHub](https://github.com/Mic92/sops-nix)
- [Mozilla SOPS Docs](https://github.com/mozilla/sops)
- [Home Manager + sops-nix](https://github.com/Mic92/sops-nix#home-manager)

### Alternativas:
- **agenix** - Más simple, solo age encryption
- **passage** - Similar a password-store pero para NixOS

---

## ✅ Checklist de Finalización

- [ ] sops-nix añadido como input en flake.nix
- [ ] Directorio secrets/ creado
- [ ] Llaves GPG/SSH configuradas en .sops.yaml
- [ ] Archivo de secretos cifrado creado
- [ ] sops-nix configurado en hosts/panther/default.nix
- [ ] Password de usuario migrado a secreto
- [ ] Home Manager configurado con sops-nix
- [ ] .gitignore actualizado para secretos
- [ ] Módulo de secretos creado (opcional)
- [ ] Documentación de uso creada para el usuario
- [ ] Sistema reconstruido exitosamente
- [ ] Usuario puede hacer login con contraseña del secreto

---

## 🚀 Comandos Clave de Implementación

```bash
# 1. Actualizar flake inputs
nix flake update

# 2. Crear estructura de secretos
mkdir -p secrets/
cd secrets/

# 3. Crear config de sops
cat > .sops.yaml << EOF
creation_rules:
  - pgp: "$(gpg --list-keys --keyid-format LONG | grep -A 1 '[uid]' | head -n 1 | awk '{print $2}')"
EOF

# 4. Crear archivo de secretos
cat > secrets.yaml << EOF
kx_password: "generar_con_mkpasswd"
kx_email: "kcurtet@gmail.com"
EOF

# 5. Cifrar secretos
sops secrets.yaml

# 6. Volver al root y rebuild
cd ../
sudo nixos-rebuild switch --flake .#panther

# 7. Verificar secretos
ls -la /run/secrets/
```
