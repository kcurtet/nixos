{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    gnome-shell = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        {
          package = appindicator;
          id = appindicator.extensionUuid;
        }
        {package = gsconnect;}
        {package = caffeine;}
        {package = pano;}
        {package = gemini-ai;}
        {package = dash-to-panel;}
        {
          id = "user-theme@gnome-shell-extensions.gcampax.github.com";
          package = pkgs.gnome-shell-extensions;
        }
        {package = gamemode-shell-extension;}
      ];
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
    };
    ghostty = {
      enable = true;
      settings = {
        theme = "Nord";
        font-size = 14;
        keybind = [
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+l=goto_split:right"
        ];
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
    };

    autojump.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zellij = {
      enable = true;
      settings = {
        theme = "nord";
      };
    };

    bat = {
      enable = true;
      config = {theme = "Nord";};
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          # Tema Nord para Lazygit
          # Basado en https://www.nordtheme.com/
          theme = {
            # Color del borde de la ventana activa (nord8 - azul brillante)
            activeBorderColor = [
              "#88c0d0"
              "bold"
            ];

            # Color del borde de ventanas inactivas (nord3 - gris brillante)
            inactiveBorderColor = [
              "#4c566a"
            ];

            # Color del borde cuando se está buscando (nord9 - azul oscuro)
            searchingActiveBorderColor = [
              "#81a1c1"
              "bold"
            ];

            # Color de fondo de la línea seleccionada (nord1 - gris más claro que el fondo)
            selectedLineBgColor = [
              "#3b4252"
            ];

            # Color de la línea seleccionada en rango (nord2)
            selectedRangeBgColor = [
              "#434c5e"
            ];

            # Colores para commits cherry-picked
            cherryPickedCommitBgColor = [
              "#434c5e"
            ];
            cherryPickedCommitFgColor = [
              "#88c0d0"
            ];

            # Color para commits marcados (nord15 - púrpura)
            markedBaseCommitBgColor = [
              "#b48ead"
            ];
            markedBaseCommitFgColor = [
              "#2e3440"
            ];
            # Color del texto de opciones (nord8)
            optionsTextColor = [
              "#88c0d0"
            ];

            # Color por defecto del texto (nord4 - blanco nieve)
            defaultFgColor = [
              "#d8dee9"
            ];

            # Colores para cambios sin stagear (nord11 - rojo)
            unstagedChangesColor = [
              "#bf616a"
            ];

            # Colores de estado de Git
            # Cambios en staging (nord14 - verde)
            stagedChangesColor = ["#a3be8c"];

            # Archivos no rastreados (nord13 - amarillo)
            untrackedChangesColor = ["#ebcb8b"];

            # Commits remotos (nord15 - púrpura)
            remoteBranchColor = ["#b48ead"];

            # Commits locales (nord14 - verde)
            localBranchColor = ["#a3be8c"];

            # Tags (nord13 - amarillo)
            tagColor = ["#ebcb8b"];

            # Archivos modificados en reflog (nord12 - naranja)
            reflogCommitColor = ["#d08770"];

            # Commits en conflicto (nord11 - rojo)
            conflictedChangesColor = ["#bf616a"];

            # Color del autor por defecto (nord7 - cyan)
            authorColor = ["#8fbcbb"];

            # Color del commit hash (nord9 - azul)
            commitHashColor = ["#81a1c1"];

            # Color de las ramas upstream (nord10 - azul oscuro)
            upstreamColor = ["#5e81ac"];
          };
        };
        # Colores personalizados para autores específicos (opcional)
        # authorColors:
        #   'Tu Nombre': '#88c0d0'
        #   'Otro Colaborador': '#a3be8c'
      };
    };
  };

  services.tailscale-systray.enable = true;

  home.shellAliases = {
    e = "nvim";
    g = "git";
    gc = "git commit";
    wip = "git commit -am wip";

    ls = "exa";
    l = "exa -l";
    ll = "exa -la";
    tree = "exa -T";
    t = "exa -T";
    tl = "exa -T -L";

    "..." = "cd ../..";
  };

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "nswitch" ''
      sudo nixos-rebuild switch --flake /home/kx/.config/nixos
    '')
    (pkgs.writeShellScriptBin "nboot" ''
      sudo nixos-rebuild boot --flake /home/kx/.config/nixos
    '')

    netcat-openbsd

    opencode

    gnome-tweaks

    # term
    ghostty
    kitty

    # term utils
    eza
    ripgrep
    fd
    btop

    # browsers
    brave
    librewolf

    # editors
    neovim
    emacs
    vscode-fhs
    code-cursor-fhs
    zed-editor-fhs
    obsidian

    # utils
    obsidian-export

    # chat
    telegram-desktop
    discord
    discordo

    # music
    spotifywm

    # version control
    git

    # code
    nil
    nixd
    alejandra

    nodejs
    typescript
    typescript-language-server
    prettier
    eslint

    python3
    pylint
    black

    lua
    luaPackages.fennel
    stylua
    lua-language-server
    fennel-ls
  ];

  home.stateVersion = "26.05";
}
