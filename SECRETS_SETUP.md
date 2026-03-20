# Secrets Setup Guide

## NPM Token Setup

Your npm token should be stored securely using SOPS. Follow these steps:

1. **Add the token to secrets.yaml:**
   ```bash
   cd secrets
   sops secrets.yaml
   ```

2. **Add the following to the YAML file:**
   ```yaml
   npm-token: "your_actual_npm_token_here"
   ```

3. **Save and exit** - SOPS will encrypt the file automatically.

4. **Rebuild the system:**
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

5. **Verify the setup:**
   ```bash
   cat ~/.npmrc
   # Should show: //registry.npmjs.org/:_authToken=<your_token>
   ```

The systemd service `setup-npm-token-for-kx` will automatically generate `~/.npmrc` on boot using the decrypted secret from `/run/secrets/npm-token`.

## Initial Password

The default user password is set to `secret` for first boot. **Change it immediately:**

```bash
passwd
```

For production deployments, consider managing the initial password via SOPS secrets as well.

## Other Secrets

Currently configured secrets:
- `zai_api_key` - Zai API key
- `brave_api_key` - Brave API key
- `npm-token` - npm registry authentication token

All secrets are stored in `secrets/secrets.yaml` and encrypted using age.
Decrypted secrets are mounted to `/run/secrets/` with restricted permissions (0600).

## Regenerating Age Keys

If you need to regenerate your age encryption keys:

```bash
nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
```

Update the public key in `secrets/.sops.yaml` and re-encrypt all secrets.
