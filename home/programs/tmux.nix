# tmux.nix — Módulo Home Manager
# Incluir en tu home.nix o imports
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.bash}/bin/bash"; # Cambia a tu shell (bash, fish, etc.)
    terminal = "tmux-256color";
    prefix = "M-a";
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 50000;
    disableConfirmationPrompt = true;
    focusEvents = true;
    aggressiveResize = true;
    clock24 = true;
    newSession = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.tmux-which-key;
        extraConfig = ''
          # Must be set before plugin loads to prevent writing to Nix store
          set -g @tmux-which-key-disable-autobuild 1
        '';
      }
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.cpu
      tmuxPlugins.copy-toolkit
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];

    extraConfig = ''
      # ─── General ──────────────────────────────────────────────
      set -ag terminal-overrides ",xterm-256color:RGB"
      set  -g extended-keys
      set -g extended-keys-format csi-u
      set-option -g allow-passthrough on


      # ─── Recargar config ─────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config recargada"

      # ─── Sessiones ─────────────────
      bind 0 choose-session
      bind N new-session -c "#{pane_current_path}"

      # ─── Navegación entre paneles (vim hjkl) ─────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Alt + hjkl sin prefix
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ─── Splits (cómodos en QWERTY ES) ───────────────────────
      unbind '"'
      unbind %
      bind v   split-window -h -c "#{pane_current_path}"
      bind s   split-window -v -c "#{pane_current_path}"
      bind '\' split-window -h -c "#{pane_current_path}"
      bind '-' split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

      # ─── Redimensionar paneles (HJKL) ────────────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind -n M-H resize-pane -L 2
      bind -n M-J resize-pane -D 2
      bind -n M-K resize-pane -U 2
      bind -n M-L resize-pane -R 2

      # ─── Navegación entre ventanas ───────────────────────────
      bind -r 1 select-window -t 1
      bind -r 2 select-window -t 2
      bind -r 3 select-window -t 3
      bind -r 4 select-window -t 4
      bind -r 5 select-window -t 5
      bind -r 6 select-window -t 6
      bind -r 7 select-window -t 7
      bind -r 8 select-window -t 8
      bind -r 9 select-window -t 9

      bind -r '<' select-window -p
      bind -r '>' select-window -n
      bind -n -r M-p previous-window
      bind -n -r M-n next-window
      bind 0 choose-window


      # ─── Gestión de paneles ──────────────────────────────────
      bind x   kill-pane
      bind X   kill-window
      bind z   resize-pane -Z
      bind Space   next-layout

      bind -r '{' swap-pane -U
      bind -r '}' swap-pane -D

      # ─── Modo copia (vi-style) ──────────────────────────────
      bind Escape copy-mode
      bind -T copy-mode-vi v      send -X begin-selection
      bind -T copy-mode-vi V      send -X select-line
      bind -T copy-mode-vi C-v    send -X rectangle-toggle
      bind -T copy-mode-vi y      send -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send -X cancel

      bind -T copy-mode-vi '/'    command-prompt -i -p "(buscar abajo)" "send -X search-forward-incremental \"%%%\""
      bind -T copy-mode-vi '?'    command-prompt -i -p "(buscar arriba)" "send -X search-backward-incremental \"%%%\""

      bind p paste-buffer
      bind b choose-buffer

      # ─── Barra de estado ────────────────────────────────────
      set -g status-position top
      set -g status-interval 5
      set -g status-justify centre

      set -g status-style "bg=#1e1e2e,fg=#cdd6f4"

      set -g status-left-length 30
      set -g status-left "#[fg=#1e1e2e,bg=#89b4fa,bold]  #S #[fg=#89b4fa,bg=#1e1e2e,nobold]"

      setw -g window-status-format         "#[fg=#6c7086] #I:#W "
      setw -g window-status-current-format "#[fg=#1e1e2e,bg=#a6e3a1,bold] #I:#W #[fg=#a6e3a1,bg=#1e1e2e,nobold]"
      setw -g window-status-separator      ""

      set -g status-right-length 50
      set -g status-right "#[fg=#f9e2af,bg=#1e1e2e] 󰥔 %H:%M #[fg=#1e1e2e,bg=#f9e2af,bold] #H "

      set -g pane-border-lines heavy
      set -g pane-border-style        "fg=#313244"
      set -g pane-active-border-style "fg=#89b4fa"

      set -g message-style "bg=#89b4fa,fg=#1e1e2e,bold"
    '';
  };
}
